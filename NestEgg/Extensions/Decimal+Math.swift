import Foundation

extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    static func safeDivide(_ numerator: Decimal, _ denominator: Decimal) -> Decimal? {
        guard denominator != 0 else { return nil }
        return numerator / denominator
    }
}
