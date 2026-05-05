import Foundation

enum MonthSeries {
    typealias Point = (month: MonthKey, amount: Decimal)

    /// Forward-fill a single asset's monthly values across the inclusive range.
    /// Months before the asset's first valuation are absent (not zero) — the caller
    /// decides whether to treat absence as zero when summing into a portfolio.
    static func forwardFill(asset: Asset, from start: MonthKey, to end: MonthKey) -> [Point] {
        guard start <= end else { return [] }
        let valuations = asset.sortedValuations
        guard !valuations.isEmpty else { return [] }

        var result: [Point] = []
        var lastAmount: Decimal? = nil
        var idx = 0
        var cursor = start
        while cursor <= end {
            while idx < valuations.count, valuations[idx].monthKey <= cursor.rawValue {
                lastAmount = valuations[idx].amount
                idx += 1
            }
            if let amt = lastAmount {
                result.append((cursor, amt))
            }
            cursor = cursor.adding(months: 1)
        }
        return result
    }

    /// Sum of forward-filled per-asset series across a portfolio.
    /// Liabilities are subtracted. Archived assets are skipped.
    static func portfolioSeries(assets: [Asset], from start: MonthKey, to end: MonthKey) -> [Point] {
        guard start <= end else { return [] }
        var totals: [Int: Decimal] = [:]
        for asset in assets where !asset.isArchived {
            let sign: Decimal = asset.isLiability ? -1 : 1
            for (month, amount) in forwardFill(asset: asset, from: start, to: end) {
                totals[month.rawValue, default: 0] += amount * sign
            }
        }
        var cursor = start
        var result: [Point] = []
        while cursor <= end {
            if let amt = totals[cursor.rawValue] {
                result.append((cursor, amt))
            }
            cursor = cursor.adding(months: 1)
        }
        return result
    }
}
