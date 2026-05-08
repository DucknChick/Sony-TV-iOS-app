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

    /// Wipes all data and replaces it with the contents of a decoded backup.
    /// Inserts categories first so asset relationships can resolve by name.
    static func replaceAllData(with backup: BackupV1, in context: ModelContext) throws {
        try? context.delete(model: Valuation.self)
        try? context.delete(model: Asset.self)
        try? context.delete(model: Category.self)
        try context.save()

        var categoriesByName: [String: Category] = [:]
        for dto in backup.categories {
            let category = Category(
                name: dto.name,
                isLiability: dto.isLiability,
                sortOrder: dto.sortOrder,
                isBuiltIn: dto.isBuiltIn,
                tracksCostBasis: dto.tracksCostBasis,
                colorHex: dto.colorHex
            )
            context.insert(category)
            categoriesByName[dto.name] = category
        }

        for dto in backup.assets {
            let category = dto.categoryName.flatMap { categoriesByName[$0] }
            let owner = Owner(rawValue: dto.owner) ?? .joint
            let asset = Asset(
                name: dto.name,
                category: category,
                institution: dto.institution,
                notes: dto.notes,
                purchaseDate: dto.purchaseDate,
                costBasis: dto.costBasis.flatMap { Decimal(string: $0) },
                owner: owner
            )
            asset.id = dto.id
            asset.createdAt = dto.createdAt
            asset.archivedAt = dto.archivedAt
            context.insert(asset)

            for vDto in dto.valuations {
                guard let amount = Decimal(string: vDto.amount) else { continue }
                let valuation = Valuation(monthKey: vDto.monthKey, amount: amount, asset: asset)
                valuation.id = vDto.id
                valuation.recordedAt = vDto.recordedAt
                context.insert(valuation)
            }
        }

        try context.save()
    }
}
