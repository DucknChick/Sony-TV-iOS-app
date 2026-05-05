import Foundation
import Observation

@MainActor
@Observable
final class AssetDetailViewModel {
    let asset: Asset

    init(asset: Asset) {
        self.asset = asset
    }

    var currentValue: Decimal { asset.currentValue }

    var costBasis: Decimal? { asset.costBasis }

    var totalReturn: Decimal? {
        guard let cost = asset.costBasis else { return nil }
        return ReturnsCalculator.totalReturn(current: currentValue, costBasis: cost)
    }

    var gainLoss: ReturnsCalculator.GainLoss? {
        guard let cost = asset.costBasis else { return nil }
        return ReturnsCalculator.gainLoss(current: currentValue, costBasis: cost)
    }

    var annualizedReturn: Decimal? {
        guard let cost = asset.costBasis, let purchase = asset.purchaseDate else { return nil }
        return ReturnsCalculator.annualizedReturn(
            current: currentValue,
            costBasis: cost,
            purchaseDate: purchase
        )
    }

    /// Chart series — forward-filled from the asset's earliest month through this month.
    var chartSeries: [MonthSeries.Point] {
        guard let first = asset.sortedValuations.first else { return [] }
        let start = MonthKey(rawValue: first.monthKey)
        let end = MonthKey.current()
        let range = start <= end ? (start, end) : (start, start)
        return MonthSeries.forwardFill(asset: asset, from: range.0, to: range.1)
    }
}
