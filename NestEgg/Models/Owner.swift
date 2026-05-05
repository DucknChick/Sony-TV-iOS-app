import Foundation

enum Owner: String, CaseIterable, Codable, Identifiable {
    case mine
    case hers
    case joint

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mine: return "Mine"
        case .hers: return "Hers"
        case .joint: return "Joint"
        }
    }
}
