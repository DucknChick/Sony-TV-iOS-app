import SwiftUI

@main
struct SonyTVRemoteApp: App {
    private let persistence = TVPersistenceService()
    private let discoveryService = TVDiscoveryService()
    private let pairingService = TVPairingService()
    private let commandService = TVCommandService()

    var body: some Scene {
        WindowGroup {
            RootView(
                persistence: persistence,
                discoveryService: discoveryService,
                pairingService: pairingService,
                commandService: commandService
            )
        }
    }
}
