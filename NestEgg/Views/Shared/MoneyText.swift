import SwiftUI

struct MoneyText: View {
    let amount: Decimal
    var compact: Bool = false
    var signed: Bool = false
    var animated: Bool = false

    var body: some View {
        let text = Text(formatted).monospacedDigit()
        if animated {
            text.contentTransition(.numericText())
        } else {
            text
        }
    }

    private var formatted: String {
        if signed { return amount.signedCurrencyUSD }
        return compact ? amount.compactCurrencyUSD : amount.currencyUSD
    }
}
