import Foundation

enum OwnerScope: String, CaseIterable, Identifiable {
    case all
    case mine
    case hers
    case joint

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .mine: return "Mine"
        case .hers: return "Hers"
        case .joint: return "Joint"
        }
    }

    func matches(_ owner: Owner) -> Bool {
        switch self {
        case .all: return true
        case .mine: return owner == .mine
        case .hers: return owner == .hers
        case .joint: return owner == .joint
        }
    }

    func filter(_ assets: [Asset]) -> [Asset] {
        guard self != .all else { return assets }
        return assets.filter { matches($0.owner) }
    }
}
