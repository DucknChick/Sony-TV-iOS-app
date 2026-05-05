import Foundation

enum ReturnsCalculator {
    /// (current - cost) / cost. Returns nil when cost basis is missing or zero.
    static func totalReturn(current: Decimal, costBasis: Decimal) -> Decimal? {
        guard costBasis > 0 else { return nil }
        return (current - costBasis) / costBasis
    }

    /// Annualized return: ((1 + r)^(1/years)) - 1.
    /// Holdings shorter than ~30 days return the simple total return instead.
    static func annualizedReturn(current: Decimal,
                                 costBasis: Decimal,
                                 purchaseDate: Date,
                                 asOf: Date = .now) -> Decimal? {
        guard let r = totalReturn(current: current, costBasis: costBasis) else { return nil }
        let days = asOf.timeIntervalSince(purchaseDate) / 86_400
        guard days >= 30 else { return r }
        let years = days / 365.25
        let rDouble = r.doubleValue
        // Guard against complex/NaN results when current goes to 0 or negative
        let base = 1 + rDouble
        guard base > 0, years > 0 else { return r }
        let annual = pow(base, 1 / years) - 1
        return Decimal(annual)
    }

    struct GainLoss {
        let absolute: Decimal
        let percent: Decimal?
    }

    static func gainLoss(current: Decimal, costBasis: Decimal) -> GainLoss {
        GainLoss(
            absolute: current - costBasis,
            percent: totalReturn(current: current, costBasis: costBasis)
        )
    }
}
