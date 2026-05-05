import Foundation
import SwiftData

@Model
final class Asset {
    var id: UUID
    var name: String
    var institution: String?
    var notes: String?
    var purchaseDate: Date?
    var costBasis: Decimal?
    var ownerRaw: String
    var createdAt: Date
    var archivedAt: Date?

    var category: Category?

    @Relationship(deleteRule: .cascade, inverse: \Valuation.asset)
    var valuations: [Valuation] = []

    init(name: String,
         category: Category? = nil,
         institution: String? = nil,
         notes: String? = nil,
         purchaseDate: Date? = nil,
         costBasis: Decimal? = nil,
         owner: Owner = .joint) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.institution = institution
        self.notes = notes
        self.purchaseDate = purchaseDate
        self.costBasis = costBasis
        self.ownerRaw = owner.rawValue
        self.createdAt = .now
    }

    var owner: Owner {
        get { Owner(rawValue: ownerRaw) ?? .joint }
        set { ownerRaw = newValue.rawValue }
    }

    var isLiability: Bool { category?.isLiability ?? false }
    var tracksCostBasis: Bool { category?.tracksCostBasis ?? false }
    var isArchived: Bool { archivedAt != nil }

    var sortedValuations: [Valuation] {
        valuations.sorted { $0.monthKey < $1.monthKey }
    }

    func valuation(for monthKey: MonthKey) -> Valuation? {
        valuations.first { $0.monthKey == monthKey.rawValue }
    }

    var latestValuation: Valuation? {
        valuations.max { $0.monthKey < $1.monthKey }
    }

    var currentValue: Decimal { latestValuation?.amount ?? 0 }
}
