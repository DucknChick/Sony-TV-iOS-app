import Foundation
import SwiftData

enum SeedService {
    /// Idempotent. If `force` is true, re-creates any missing built-ins
    /// regardless of whether the store has data.
    static func seedIfNeeded(in context: ModelContext, force: Bool = false) {
        let descriptor = FetchDescriptor<Category>()
        let existing = (try? context.fetch(descriptor)) ?? []
        let existingByName = Dictionary(uniqueKeysWithValues: existing.map { ($0.name, $0) })

        var inserted = false
        for seed in SeedData.builtInCategories {
            if existingByName[seed.name] == nil {
                let cat = Category(
                    name: seed.name,
                    isLiability: seed.isLiability,
                    sortOrder: seed.sortOrder,
                    isBuiltIn: true,
                    tracksCostBasis: seed.tracksCostBasis
                )
                context.insert(cat)
                inserted = true
            }
        }
        if inserted || force {
            try? context.save()
        }
    }
}
