import SwiftUI

struct MoneyText: View {
    let amount: Decimal
    var compact: Bool = false
    var signed: Bool = false

    var body: some View {
        Text(formatted)
            .monospacedDigit()
    }

    private var formatted: String {
        if signed { return amount.signedCurrencyUSD }
        return compact ? amount.compactCurrencyUSD : amount.currencyUSD
    }
}
