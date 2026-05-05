import Foundation
import SwiftData

enum PersistenceController {
    static let schema = Schema([
        Category.self,
        Asset.self,
        Valuation.self,
    ])

    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// Insert or update the (asset, monthKey) valuation. Enforces compound
    /// uniqueness manually because SwiftData has no compound `@Attribute(.unique)`.
    @discardableResult
    static func upsertValuation(amount: Decimal,
                                month: MonthKey,
                                asset: Asset,
                                in context: ModelContext) -> Valuation {
        let monthRaw = month.rawValue
        if let existing = asset.valuation(for: month) {
            existing.amount = amount
            existing.recordedAt = .now
            try? context.save()
            return existing
        }
        let valuation = Valuation(monthKey: monthRaw, amount: amount, asset: asset)
        context.insert(valuation)
        try? context.save()
        return valuation
    }

    static func deleteValuation(_ valuation: Valuation, in context: ModelContext) {
        context.delete(valuation)
        try? context.save()
    }

    static func deleteAsset(_ asset: Asset, in context: ModelContext) {
        context.delete(asset)
        try? context.save()
    }

    /// Wipes all user data and re-seeds default categories.
    static func resetAllData(in context: ModelContext) {
        try? context.delete(model: Valuation.self)
        try? context.delete(model: Asset.self)
        try? context.delete(model: Category.self)
        try? context.save()
        SeedService.seedIfNeeded(in: context, force: true)
    }
}
