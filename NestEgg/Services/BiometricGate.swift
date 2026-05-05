import Foundation
import LocalAuthentication
import Observation

@Observable
final class BiometricGate {
    enum State: Equatable {
        case locked
        case authenticating
        case unlocked
        case failed(String)
    }

    var state: State = .locked
    var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey) }
    }

    private static let enabledKey = "BiometricGate.enabled"
    private let reason = "Unlock NestEgg to view your finances."

    init() {
        self.isEnabled = UserDefaults.standard.object(forKey: Self.enabledKey) as? Bool ?? true
    }

    var isUnlocked: Bool {
        if !isEnabled { return true }
        if case .unlocked = state { return true }
        return false
    }

    func lock() {
        guard isEnabled else { return }
        state = .locked
    }

    func authenticate() async {
        guard isEnabled else {
            state = .unlocked
            return
        }
        state = .authenticating

        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        var error: NSError?
        let policy: LAPolicy = .deviceOwnerAuthentication
        guard context.canEvaluatePolicy(policy, error: &error) else {
            // No biometrics and no passcode set — fail open so the user isn't bricked out.
            state = .unlocked
            return
        }

        do {
            let success = try await context.evaluatePolicy(policy, localizedReason: reason)
            state = success ? .unlocked : .failed("Authentication failed.")
        } catch let laError as LAError where laError.code == .userCancel || laError.code == .appCancel || laError.code == .systemCancel {
            state = .locked
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
