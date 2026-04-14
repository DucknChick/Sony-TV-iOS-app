import Foundation
import Network

enum WakeOnLANError: LocalizedError {
    case invalidMACAddress
    case sendFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidMACAddress:
            return "Invalid MAC address format."
        case .sendFailed(let error):
            return "Failed to send Wake-on-LAN packet: \(error.localizedDescription)"
        }
    }
}

final class WakeOnLANClient {

    func wake(macAddress: String) async throws {
        let packet = try buildMagicPacket(macAddress: macAddress)
        try await sendUDP(data: packet, to: "255.255.255.255", port: 9)
    }

    private func buildMagicPacket(macAddress: String) throws -> Data {
        // Strip common separators
        let hex = macAddress.replacingOccurrences(of: ":", with: "")
                             .replacingOccurrences(of: "-", with: "")
                             .replacingOccurrences(of: ".", with: "")

        guard hex.count == 12 else { throw WakeOnLANError.invalidMACAddress }

        var macBytes = [UInt8]()
        var index = hex.startIndex
        for _ in 0..<6 {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else {
                throw WakeOnLANError.invalidMACAddress
            }
            macBytes.append(byte)
            index = nextIndex
        }

        // Magic packet: 6x 0xFF + 16x MAC address
        var packet = Data(repeating: 0xFF, count: 6)
        for _ in 0..<16 {
            packet.append(contentsOf: macBytes)
        }
        return packet
    }

    private func sendUDP(data: Data, to address: String, port: Int) async throws {
        let host = NWEndpoint.Host(address)
        let nwPort = NWEndpoint.Port(rawValue: UInt16(port))!

        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true

        let connection = NWConnection(host: host, port: nwPort, using: params)
        let queue = DispatchQueue(label: "com.sonytvremote.wol")

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    connection.send(content: data, completion: .contentProcessed { error in
                        connection.cancel()
                        if let error {
                            continuation.resume(throwing: WakeOnLANError.sendFailed(error))
                        } else {
                            continuation.resume()
                        }
                    })
                case .failed(let error):
                    continuation.resume(throwing: WakeOnLANError.sendFailed(error))
                default:
                    break
                }
            }
            connection.start(queue: queue)
        }
    }
}
