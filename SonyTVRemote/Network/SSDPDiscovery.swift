import Foundation
import Network

struct SSDPResponse {
    let ipAddress: String
    let location: String
    let usn: String
    let server: String?
}

struct TVDeviceInfo {
    let friendlyName: String
    let macAddress: String?
    let modelName: String?
}

protocol SSDPDiscoveryDelegate: AnyObject {
    func discoveryDidFind(response: SSDPResponse)
    func discoveryDidFinish()
    func discoveryDidFail(error: Error)
}

final class SSDPDiscovery: NSObject {

    weak var delegate: SSDPDiscoveryDelegate?
    private var connection: NWConnection?
    private var timeoutTask: Task<Void, Never>?
    private var isStopped = false
    private var seenUSNs = Set<String>()
    private let queue = DispatchQueue(label: "com.sonytvremote.ssdp", qos: .userInitiated)

    private let mSearchMessage = """
        M-SEARCH * HTTP/1.1\r\n\
        HOST: 239.255.255.250:1900\r\n\
        MAN: "ssdp:discover"\r\n\
        MX: 3\r\n\
        ST: urn:schemas-sony-com:service:IRCC:1\r\n\
        \r\n
        """

    func startDiscovery(timeout: TimeInterval = 6.0) {
        isStopped = false
        seenUSNs = []

        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true

        let host = NWEndpoint.Host("239.255.255.250")
        let port = NWEndpoint.Port(rawValue: 1900)!

        connection = NWConnection(host: host, port: port, using: params)

        connection?.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                self.sendMSearch()
                self.receiveLoop()
            case .failed(let error):
                self.delegate?.discoveryDidFail(error: error)
                self.stopDiscovery()
            default:
                break
            }
        }

        connection?.start(queue: queue)

        timeoutTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            if !self.isStopped {
                self.stopDiscovery()
                await MainActor.run { self.delegate?.discoveryDidFinish() }
            }
        }
    }

    func stopDiscovery() {
        isStopped = true
        timeoutTask?.cancel()
        connection?.cancel()
        connection = nil
    }

    private func sendMSearch() {
        guard let data = mSearchMessage.data(using: .utf8) else { return }
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error {
                print("[SSDP] Send error: \(error)")
            }
        })
    }

    private func receiveLoop() {
        guard !isStopped else { return }
        connection?.receiveMessage { [weak self] data, _, isComplete, error in
            guard let self, !self.isStopped else { return }
            if let data, let text = String(data: data, encoding: .utf8) {
                self.parseResponse(text)
            }
            if let error {
                print("[SSDP] Receive error: \(error)")
            }
            self.receiveLoop()
        }
    }

    private func parseResponse(_ text: String) {
        guard text.hasPrefix("HTTP/1.1 200 OK") || text.lowercased().contains("notify") else { return }

        var headers: [String: String] = [:]
        let lines = text.components(separatedBy: "\r\n")
        for line in lines.dropFirst() {
            guard let colonIdx = line.firstIndex(of: ":") else { continue }
            let key = String(line[line.startIndex..<colonIdx]).trimmingCharacters(in: .whitespaces).uppercased()
            let value = String(line[line.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
            headers[key] = value
        }

        guard let location = headers["LOCATION"], !location.isEmpty else { return }
        let usn = headers["USN"] ?? location
        guard !seenUSNs.contains(usn) else { return }
        seenUSNs.insert(usn)

        guard let url = URL(string: location), let host = url.host else { return }

        let response = SSDPResponse(
            ipAddress: host,
            location: location,
            usn: usn,
            server: headers["SERVER"]
        )

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.discoveryDidFind(response: response)
        }
    }
}

// MARK: - UPnP Device Description Fetcher

final class UPnPDeviceDescriptionFetcher: NSObject, XMLParserDelegate {

    private var currentElement = ""
    private var result = TVDeviceInfo(friendlyName: "Sony TV", macAddress: nil, modelName: nil)
    private var friendlyName: String?
    private var modelName: String?
    private var macAddress: String?
    private var characters = ""

    func fetch(location: String) async throws -> TVDeviceInfo {
        guard let url = URL(string: location) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try parse(data: data)
    }

    private func parse(data: Data) throws -> TVDeviceInfo {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return TVDeviceInfo(
            friendlyName: friendlyName ?? "Sony TV",
            macAddress: macAddress,
            modelName: modelName
        )
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        characters = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        characters += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        let value = characters.trimmingCharacters(in: .whitespacesAndNewlines)
        switch elementName {
        case "friendlyName":
            friendlyName = value
        case "modelName":
            modelName = value
        case "X_MAC_ADDR":
            macAddress = value
        default:
            break
        }
        characters = ""
    }
}
