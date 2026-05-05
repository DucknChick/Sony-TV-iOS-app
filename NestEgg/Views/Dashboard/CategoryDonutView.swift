import SwiftUI
import Charts

struct CategoryDonutView: View {
    let title: String
    let breakdown: [NetWorthAggregator.CategoryBreakdown]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            if breakdown.isEmpty {
                Text("No data yet.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: 16) {
                    Chart(breakdown) { slice in
                        SectorMark(
                            angle: .value("Amount", slice.amount.doubleValue),
                            innerRadius: .ratio(0.62),
                            angularInset: 1.5
                        )
                        .cornerRadius(2)
                        .foregroundStyle(color(for: slice.category))
                    }
                    .frame(width: 140, height: 140)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(breakdown) { slice in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(color(for: slice.category))
                                    .frame(width: 10, height: 10)
                                Text(slice.category.name)
                                    .font(.subheadline)
                                Spacer()
                                Text(slice.amount.compactCurrencyUSD)
                                    .font(.subheadline)
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private func color(for category: Category) -> Color {
        if let hex = category.colorHex, let c = Color(hex: hex) { return c }
        return Color.forCategoryName(category.name)
    }
}
