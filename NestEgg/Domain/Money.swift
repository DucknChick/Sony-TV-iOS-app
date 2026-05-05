import Foundation

typealias Money = Decimal

extension Decimal {
    var currencyUSD: String {
        formatted(.currency(code: "USD"))
    }

    var compactCurrencyUSD: String {
        formatted(.currency(code: "USD").notation(.compactName))
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
