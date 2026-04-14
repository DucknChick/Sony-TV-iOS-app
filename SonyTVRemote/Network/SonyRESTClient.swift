import Foundation

enum RESTError: LocalizedError {
    case notAuthorized
    case serverError([Int])
    case decodingFailed
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Not authorized. Please pair with your TV again."
        case .serverError(let codes):
            return "TV returned error codes: \(codes)."
        case .decodingFailed:
            return "Failed to decode TV response."
        case .invalidResponse:
            return "Invalid response from TV."
        }
    }
}

// Raw JSON-RPC envelope
private struct RPCRequest: Encodable {
    let method: String
    let params: [AnyCodable]
    let id: Int
    let version: String
}

private struct RPCResponse: Decodable {
    let result: [AnyCodable]?
    let error: [AnyCodable]?
    let id: Int?
}

// Type-erased Codable wrapper
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(Int.self) { value = v }
        else if let v = try? container.decode(Double.self) { value = v }
        else if let v = try? container.decode(String.self) { value = v }
        else if let v = try? container.decode(Bool.self) { value = v }
        else if let v = try? container.decode([AnyCodable].self) { value = v.map { $0.value } }
        else if let v = try? container.decode([String: AnyCodable].self) { value = v.mapValues { $0.value } }
        else { value = NSNull() }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let v as Int:            try container.encode(v)
        case let v as Double:         try container.encode(v)
        case let v as String:         try container.encode(v)
        case let v as Bool:           try container.encode(v)
        case let v as [Any]:          try container.encode(v.map { AnyCodable($0) })
        case let v as [String: Any]:  try container.encode(v.mapValues { AnyCodable($0) })
        default:                      try container.encodeNil()
        }
    }
}

final class SonyRESTClient {
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var authCookie: String?

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Generic request

    @discardableResult
    func request(
        service: TVServiceEndpoint,
        method: String,
        params: [Any],
        tv: SonyTV,
        id: Int = 1
    ) async throws -> [Any] {
        let url = tv.baseURL.appendingPathComponent(service.path.dropFirst(), isDirectory: false)

        let rpc = RPCRequest(
            method: method,
            params: params.map { AnyCodable($0) },
            id: id,
            version: "1.0"
        )
        let body = try encoder.encode(rpc)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = 10

        if let token = tv.authToken {
            request.setValue(token, forHTTPHeaderField: "X-Auth-PSK")
        }
        if let cookie = authCookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        }

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw RESTError.invalidResponse
        }

        // Capture Set-Cookie
        if let setCookie = http.value(forHTTPHeaderField: "Set-Cookie") {
            authCookie = setCookie.components(separatedBy: ";").first
        }

        if http.statusCode == 401 || http.statusCode == 403 {
            throw RESTError.notAuthorized
        }

        let rpcResponse = try decoder.decode(RPCResponse.self, from: data)

        if let error = rpcResponse.error, !error.isEmpty {
            let codes = error.compactMap { $0.value as? Int }
            throw RESTError.serverError(codes)
        }

        return rpcResponse.result?.map { $0.value } ?? []
    }

    // MARK: - actRegister (pairing)

    /// First call: no credentials → TV shows PIN → returns 401
    func initiateRegistration(tv: SonyTV) async throws {
        let payload = buildActRegisterPayload()
        var request = buildRegistrationRequest(tv: tv, body: payload)
        request.timeoutInterval = 10
        let (_, response) = try await session.data(for: request)
        // Expect 401 which triggers PIN display on TV — that's normal
        let _ = response
    }

    /// Second call: with PIN as Basic auth → returns 200 + Set-Cookie
    func completeRegistration(tv: SonyTV, pin: String) async throws -> String {
        let payload = buildActRegisterPayload()
        var request = buildRegistrationRequest(tv: tv, body: payload)

        let credentials = "user:\(pin)"
        let encoded = Data(credentials.utf8).base64EncodedString()
        request.setValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        let (_, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw RESTError.invalidResponse
        }
        guard http.statusCode == 200 else {
            throw RESTError.notAuthorized
        }

        // Extract cookie or fall back to using the PIN itself as X-Auth-PSK
        if let setCookie = http.value(forHTTPHeaderField: "Set-Cookie") {
            let cookie = setCookie.components(separatedBy: ";").first ?? pin
            authCookie = cookie
            return cookie
        }

        // Many Sony firmware versions simply accept the PIN as X-Auth-PSK
        return pin
    }

    // MARK: - Convenience

    func getInputList(tv: SonyTV) async throws -> [TVInput] {
        let results = try await request(
            service: .avContent,
            method: "getContentList",
            params: [["source": "extInput:"]],
            tv: tv
        )
        guard let items = results.first as? [[String: Any]] else { return [] }
        return items.compactMap { dict in
            guard let title = dict["title"] as? String,
                  let uri = dict["uri"] as? String else { return nil }
            return TVInput(id: uri, title: title, uri: uri, icon: dict["icon"] as? String)
        }
    }

    func getSystemInfo(tv: SonyTV) async throws -> SystemInfo {
        let results = try await request(service: .system, method: "getSystemInformation", params: [], tv: tv)
        guard let raw = results.first as? [String: Any] else { throw RESTError.decodingFailed }
        let data = try JSONSerialization.data(withJSONObject: raw)
        return try decoder.decode(SystemInfo.self, from: data)
    }

    // MARK: - Helpers

    private func buildActRegisterPayload() -> Data {
        let body: [String: Any] = [
            "method": "actRegister",
            "params": [
                [
                    "clientid": "SonyTVRemote:1",
                    "nickname": "iPhone Remote",
                    "level": "private"
                ],
                [
                    ["value": "yes", "function": "WOL"]
                ]
            ],
            "id": 1,
            "version": "1.0"
        ]
        return (try? JSONSerialization.data(withJSONObject: body)) ?? Data()
    }

    private func buildRegistrationRequest(tv: SonyTV, body: Data) -> URLRequest {
        let url = tv.baseURL.appendingPathComponent("sony/accessControl")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }
}
