import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private(set) var month: MonthKey = .current()

    func netWorth(for assets: [Asset]) -> Decimal {
        NetWorthAggregator.netWorth(assets, at: month)
    }

    func totalAssets(for assets: [Asset]) -> Decimal {
        NetWorthAggregator.totalAssets(assets, at: month)
    }

    func totalLiabilities(for assets: [Asset]) -> Decimal {
        NetWorthAggregator.totalLiabilities(assets, at: month)
    }

    func momDelta(for assets: [Asset]) -> NetWorthAggregator.Delta {
        NetWorthAggregator.monthOverMonth(assets, at: month)
    }

    func assetBreakdown(for assets: [Asset]) -> [NetWorthAggregator.CategoryBreakdown] {
        NetWorthAggregator.breakdownByCategory(assets, at: month, liabilities: false)
    }

    func liabilityBreakdown(for assets: [Asset]) -> [NetWorthAggregator.CategoryBreakdown] {
        NetWorthAggregator.breakdownByCategory(assets, at: month, liabilities: true)
    }

    func sparklineSeries(for assets: [Asset], months: Int = 12) -> [MonthSeries.Point] {
        let end = month
        let start = end.adding(months: -(months - 1))
        return MonthSeries.portfolioSeries(assets: assets, from: start, to: end)
    }

    func staleAssets(_ assets: [Asset]) -> [Asset] {
        NetWorthAggregator.staleAssets(assets, thisMonth: month)
    }
}
