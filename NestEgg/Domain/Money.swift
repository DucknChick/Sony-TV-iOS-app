import Foundation

typealias Money = Decimal

extension Decimal {
    var currencyUSD: String {
        formatted(.currency(code: "USD"))
    }

    var compactCurrencyUSD: String {
        let abs = self < 0 ? -self : self
        let (divisor, suffix): (Decimal, String)
        switch abs {
        case 1_000_000_000...: (divisor, suffix) = (1_000_000_000, "B")
        case 1_000_000...:     (divisor, suffix) = (1_000_000, "M")
        case 1_000...:         (divisor, suffix) = (1_000, "K")
        default:               return formatted(.currency(code: "USD").precision(.fractionLength(0)))
        }
        let value = (self / divisor)
        let numStr = value.formatted(.number.precision(.fractionLength(1)))
        return "$\(numStr)\(suffix)"
    }

    var signedCurrencyUSD: String {
        let sign = self >= 0 ? "+" : "−"
        let absStr = (self < 0 ? -self : self).formatted(.currency(code: "USD"))
        return "\(sign)\(absStr)"
    }

    var percentString: String {
        formatted(.percent.precision(.fractionLength(0...2)))
    }

    var signedPercentString: String {
        let sign = self >= 0 ? "+" : "−"
        let absStr = (self < 0 ? -self : self).formatted(.percent.precision(.fractionLength(0...2)))
        return "\(sign)\(absStr)"
    }
}
