import Foundation

@MainActor
final class TVPairingService: ObservableObject {
    @Published var pairingState: PairingState = .unpaired

    private let rest: SonyRESTClient

    init(rest: SonyRESTClient = SonyRESTClient()) {
        self.rest = rest
    }

    /// Step 1: Initiate pairing — TV will display a PIN
    func initiatePairing(tv: SonyTV) async {
        pairingState = .waitingForPin
        do {
            try await rest.initiateRegistration(tv: tv)
            // HTTP 401 is expected here; the TV shows its PIN
            // State remains .waitingForPin — user reads PIN from TV screen
        } catch {
            // A thrown error other than 401 means something went wrong
            // URLSession throws on network errors; 401 is handled inside REST client
            let msg = error.localizedDescription
            if !msg.lowercased().contains("401") {
                pairingState = .failed(msg)
            }
            // Otherwise remain in waitingForPin
        }
    }

    /// Step 2: Submit PIN entered by user
    func submitPin(_ pin: String, for tv: SonyTV) async -> SonyTV {
        pairingState = .verifying
        do {
            let token = try await rest.completeRegistration(tv: tv, pin: pin)
            pairingState = .paired(token: token)
            var updatedTV = tv
            updatedTV.authToken = token
            updatedTV.isPaired = true
            return updatedTV
        } catch {
            pairingState = .failed("Incorrect PIN or TV unavailable. Please try again.")
            return tv
        }
    }

    func reset() {
        pairingState = .unpaired
    }
}
