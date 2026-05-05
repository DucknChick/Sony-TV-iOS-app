import Foundation

enum NetWorthAggregator {
    struct CategoryBreakdown: Identifiable {
        let id = UUID()
        let category: Category
        let amount: Decimal
    }

    static func currentValue(of asset: Asset, at month: MonthKey) -> Decimal {
        let cutoff = month.rawValue
        let candidates = asset.valuations.filter { $0.monthKey <= cutoff }
        return candidates.max { $0.monthKey < $1.monthKey }?.amount ?? 0
    }

    static func totalAssets(_ assets: [Asset], at month: MonthKey) -> Decimal {
        assets
            .filter { !$0.isArchived && !$0.isLiability }
            .reduce(0) { $0 + currentValue(of: $1, at: month) }
    }

    static func totalLiabilities(_ assets: [Asset], at month: MonthKey) -> Decimal {
        assets
            .filter { !$0.isArchived && $0.isLiability }
            .reduce(0) { $0 + currentValue(of: $1, at: month) }
    }

    static func netWorth(_ assets: [Asset], at month: MonthKey) -> Decimal {
        totalAssets(assets, at: month) - totalLiabilities(assets, at: month)
    }

    static func breakdownByCategory(_ assets: [Asset], at month: MonthKey, liabilities: Bool) -> [CategoryBreakdown] {
        var totals: [ObjectIdentifier: (Category, Decimal)] = [:]
        for asset in assets where !asset.isArchived && asset.isLiability == liabilities {
            guard let cat = asset.category else { continue }
            let amount = currentValue(of: asset, at: month)
            guard amount != 0 else { continue }
            let key = ObjectIdentifier(cat)
            let prev = totals[key]?.1 ?? 0
            totals[key] = (cat, prev + amount)
        }
        return totals.values
            .map { CategoryBreakdown(category: $0.0, amount: $0.1) }
            .sorted { $0.amount > $1.amount }
    }

    struct Delta {
        let absolute: Decimal
        let percent: Decimal?
    }

    static func monthOverMonth(_ assets: [Asset], at month: MonthKey) -> Delta {
        let now = netWorth(assets, at: month)
        let prev = netWorth(assets, at: month.adding(months: -1))
        let delta = now - prev
        let pct: Decimal? = prev == 0 ? nil : delta / decimalAbs(prev)
        return Delta(absolute: delta, percent: pct)
    }

    static func staleAssets(_ assets: [Asset], thisMonth: MonthKey) -> [Asset] {
        assets.filter { asset in
            guard !asset.isArchived else { return false }
            return asset.valuation(for: thisMonth) == nil
        }
    }

    private static func decimalAbs(_ value: Decimal) -> Decimal {
        value < 0 ? -value : value
    }
}
