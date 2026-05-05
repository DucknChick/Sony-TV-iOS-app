import SwiftUI

struct DeltaBadge: View {
    let amount: Decimal
    let percent: Decimal?
    var showAmount: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: amount >= 0 ? "arrow.up.right" : "arrow.down.right")
            if showAmount {
                Text(amount.signedCurrencyUSD)
            }
            if let pct = percent {
                Text("(\(pct.signedPercentString))")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.caption)
        .foregroundStyle(amount >= 0 ? Color.green : Color.red)
        .monospacedDigit()
    }
}
