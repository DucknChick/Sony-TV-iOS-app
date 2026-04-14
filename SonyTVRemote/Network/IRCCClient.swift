import Foundation

enum IRCCError: LocalizedError {
    case notAuthorized
    case commandFailed(statusCode: Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Not authorized. Please pair with your TV again."
        case .commandFailed(let code):
            return "Command failed with status \(code)."
        case .invalidResponse:
            return "Received an invalid response from the TV."
        }
    }
}

final class IRCCClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func sendCommand(_ command: IRCCCommand, to tv: SonyTV) async throws {
        let request = buildRequest(for: tv, command: command)
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw IRCCError.invalidResponse
        }
        switch http.statusCode {
        case 200, 204:
            return
        case 401, 403:
            throw IRCCError.notAuthorized
        default:
            throw IRCCError.commandFailed(statusCode: http.statusCode)
        }
    }

    private func buildRequest(for tv: SonyTV, command: IRCCCommand) -> URLRequest {
        let url = tv.baseURL.appendingPathComponent("sony/IRCC")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "\"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC\"",
            forHTTPHeaderField: "SOAPAction"
        )
        if let token = tv.authToken {
            request.setValue(token, forHTTPHeaderField: "X-Auth-PSK")
        }
        request.httpBody = buildSOAPBody(command: command).data(using: .utf8)
        request.timeoutInterval = 8
        return request
    }

    private func buildSOAPBody(command: IRCCCommand) -> String {
        """
        <?xml version="1.0"?>
        <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" \
        s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
          <s:Body>
            <u:X_SendIRCC xmlns:u="urn:schemas-sony-com:service:IRCC:1">
              <IRCCCode>\(command.rawValue)</IRCCCode>
            </u:X_SendIRCC>
          </s:Body>
        </s:Envelope>
        """
    }
}
