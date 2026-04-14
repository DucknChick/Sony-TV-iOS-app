import Foundation

@MainActor
final class PairingViewModel: ObservableObject {
    @Published var pin: String = ""
    @Published var pairingState: PairingState = .unpaired

    let tv: SonyTV
    private let pairingService: TVPairingService
    private let persistence: TVPersistenceService

    var canConfirm: Bool { pin.count >= 4 }

    var isLoading: Bool {
        pairingState == .waitingForPin || pairingState == .verifying
    }

    init(tv: SonyTV, pairingService: TVPairingService, persistence: TVPersistenceService) {
        self.tv = tv
        self.pairingService = pairingService
        self.persistence = persistence
    }

    func startPairing() async {
        await pairingService.initiatePairing(tv: tv)
        pairingState = pairingService.pairingState
    }

    func confirmPin() async -> SonyTV? {
        let updatedTV = await pairingService.submitPin(pin, for: tv)
        pairingState = pairingService.pairingState
        if pairingState.isPaired {
            persistence.addOrUpdate(updatedTV)
            return updatedTV
        }
        return nil
    }

    func reset() {
        pin = ""
        pairingService.reset()
        pairingState = .unpaired
    }
}
