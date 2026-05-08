import SwiftUI

struct AssetMetricsHeader: View {
    let viewModel: AssetDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    SectionLabel(text: viewModel.asset.isLiability ? "Outstanding Balance" : "Current Value")
                    Text(viewModel.currentValue.currencyUSD)
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                Spacer()
            }

            if viewModel.asset.tracksCostBasis,
               let cost = viewModel.costBasis,
               let gainLoss = viewModel.gainLoss {
                Divider()
                metricRow("Cost basis", value: cost.currencyUSD)
                metricRow(
                    "Gain / loss",
                    value: gainLoss.absolute.signedCurrencyUSD,
                    accent: gainLoss.absolute >= 0 ? .green : .red
                )
                if let pct = gainLoss.percent {
                    metricRow(
                        "Total return",
                        value: pct.signedPercentString,
                        accent: pct >= 0 ? .green : .red
                    )
                }
                if let annual = viewModel.annualizedReturn {
                    metricRow(
                        "Annualized",
                        value: annual.signedPercentString,
                        accent: annual >= 0 ? .green : .red
                    )
                }
            }
        }
    }

    private func metricRow(_ label: String, value: String, accent: Color = .primary) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(accent)
        }
    }
}
