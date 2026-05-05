import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Asset.createdAt)]) private var assets: [Asset]

    @State private var viewModel = DashboardViewModel()
    @State private var staleAssetForUpdate: Asset?

    var body: some View {
        Group {
            if assets.isEmpty {
                EmptyStateView(
                    systemImage: "chart.line.uptrend.xyaxis",
                    title: "Welcome to NestEgg",
                    message: "Add your first asset or liability to start tracking your net worth."
                )
            } else {
                content
            }
        }
        .navigationTitle("Dashboard")
        .sheet(item: $staleAssetForUpdate) { asset in
            NavigationStack {
                ValuationFormView(asset: asset, initialMonth: viewModel.month)
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroSection
                breakdownSection
                staleSection
            }
            .padding()
        }
    }

    private var heroSection: some View {
        let nw = viewModel.netWorth(for: assets)
        let delta = viewModel.momDelta(for: assets)
        let series = viewModel.sparklineSeries(for: assets)

        return VStack(alignment: .leading, spacing: 8) {
            Text("Net Worth")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(nw.currencyUSD)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HStack(spacing: 8) {
                DeltaBadge(amount: delta.absolute, percent: delta.percent)
                Text("vs last month")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !series.isEmpty {
                NetWorthSparkline(series: series)
                    .padding(.top, 4)
            }
            HStack {
                summaryStat("Assets", value: viewModel.totalAssets(for: assets))
                Divider().frame(height: 32)
                summaryStat("Liabilities", value: viewModel.totalLiabilities(for: assets))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func summaryStat(_ label: String, value: Decimal) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value.compactCurrencyUSD)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var breakdownSection: some View {
        VStack(spacing: 16) {
            CategoryDonutView(title: "Assets by Category", breakdown: viewModel.assetBreakdown(for: assets))
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            let liabilities = viewModel.liabilityBreakdown(for: assets)
            if !liabilities.isEmpty {
                CategoryDonutView(title: "Liabilities by Category", breakdown: liabilities)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    @ViewBuilder
    private var staleSection: some View {
        let stale = viewModel.staleAssets(assets)
        if !stale.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Needs an update for \(viewModel.month.shortLabel)")
                    .font(.headline)
                ForEach(Array(stale.enumerated()), id: \.element.id) { idx, asset in
                    StaleAssetRow(asset: asset) {
                        staleAssetForUpdate = asset
                    }
                    .padding(.vertical, 4)
                    if idx < stale.count - 1 {
                        Divider()
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
