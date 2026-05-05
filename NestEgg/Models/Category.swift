import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var name: String
    var isLiability: Bool
    var sortOrder: Int
    var isBuiltIn: Bool
    var tracksCostBasis: Bool
    var colorHex: String?

    @Relationship(deleteRule: .nullify, inverse: \Asset.category)
    var assets: [Asset] = []

    init(name: String,
         isLiability: Bool,
         sortOrder: Int,
         isBuiltIn: Bool,
         tracksCostBasis: Bool,
         colorHex: String? = nil) {
        self.name = name
        self.isLiability = isLiability
        self.sortOrder = sortOrder
        self.isBuiltIn = isBuiltIn
        self.tracksCostBasis = tracksCostBasis
        self.colorHex = colorHex
    }
}
