import Foundation

@MainActor
final class TVDiscoveryService: ObservableObject {
    @Published var discoveredTVs: [SonyTV] = []
    @Published var isScanning: Bool = false
    @Published var error: String?

    private let ssdp = SSDPDiscovery()
    private let descriptionFetcher = UPnPDeviceDescriptionFetcher()
    private let rest = SonyRESTClient()
    private var seenIPs = Set<String>()

    init() {
        ssdp.delegate = self
    }

    func startScan() {
        discoveredTVs = []
        seenIPs = []
        error = nil
        isScanning = true
        ssdp.startDiscovery(timeout: 6.0)
    }

    func stopScan() {
        ssdp.stopDiscovery()
        isScanning = false
    }

    func addManually(ipAddress: String) -> SonyTV {
        let tv = SonyTV(name: "Sony TV (\(ipAddress))", ipAddress: ipAddress)
        if !discoveredTVs.contains(where: { $0.ipAddress == ipAddress }) {
            discoveredTVs.append(tv)
        }
        return tv
    }

    private func handleSSDPResponse(_ response: SSDPResponse) {
        guard !seenIPs.contains(response.ipAddress) else { return }
        seenIPs.insert(response.ipAddress)

        Task {
            var name = "Sony TV"
            var macAddress: String?

            if let info = try? await descriptionFetcher.fetch(location: response.location) {
                name = info.friendlyName
                macAddress = info.macAddress
            }

            let tv = SonyTV(
                name: name,
                ipAddress: response.ipAddress,
                macAddress: macAddress
            )

            await MainActor.run {
                if !self.discoveredTVs.contains(where: { $0.ipAddress == tv.ipAddress }) {
                    self.discoveredTVs.append(tv)
                }
            }
        }
    }
}

extension TVDiscoveryService: SSDPDiscoveryDelegate {
    nonisolated func discoveryDidFind(response: SSDPResponse) {
        Task { @MainActor in
            self.handleSSDPResponse(response)
        }
    }

    nonisolated func discoveryDidFinish() {
        Task { @MainActor in
            self.isScanning = false
        }
    }

    nonisolated func discoveryDidFail(error: Error) {
        Task { @MainActor in
            self.isScanning = false
            let nsError = error as NSError
            if nsError.domain == "NWErrorDomainPOSIX" && nsError.code == 1 {
                self.error = "Local network access denied. Enable it in Settings > Privacy."
            } else {
                self.error = error.localizedDescription
            }
        }
    }
}
