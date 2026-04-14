import Foundation

enum PairingState: Equatable {
    case unpaired
    case waitingForPin
    case verifying
    case paired(token: String)
    case failed(String)

    static func == (lhs: PairingState, rhs: PairingState) -> Bool {
        switch (lhs, rhs) {
        case (.unpaired, .unpaired):           return true
        case (.waitingForPin, .waitingForPin): return true
        case (.verifying, .verifying):         return true
        case (.paired(let a), .paired(let b)): return a == b
        case (.failed(let a), .failed(let b)): return a == b
        default:                               return false
        }
    }

    var isPaired: Bool {
        if case .paired = self { return true }
        return false
    }

    var isLoading: Bool {
        switch self {
        case .waitingForPin, .verifying: return true
        default: return false
        }
    }

    var errorMessage: String? {
        if case .failed(let msg) = self { return msg }
        return nil
    }

    var token: String? {
        if case .paired(let t) = self { return t }
        return nil
    }
}
