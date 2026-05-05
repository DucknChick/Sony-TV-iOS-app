import SwiftUI

struct AssetValuationRow: View {
    let valuation: Valuation

    var body: some View {
        HStack {
            Text(MonthKey(rawValue: valuation.monthKey).shortLabel)
                .font(.subheadline)
            Spacer()
            Text(valuation.amount.currencyUSD)
                .font(.subheadline)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
