import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Asset.createdAt)]) private var assets: [Asset]

    @AppStorage("dashboard.ownerScope") private var ownerScopeRaw: String = OwnerScope.all.rawValue

    @State private var viewModel = DashboardViewModel()
    @State private var staleAssetForUpdate: Asset?

    private var scope: OwnerScope {
        OwnerScope(rawValue: ownerScopeRaw) ?? .all
    }

    private var scopeBinding: Binding<OwnerScope> {
        Binding(
            get: { scope },
            set: { newValue in
                ownerScopeRaw = newValue.rawValue
                Haptics.tap()
            }
        )
    }

    private var filteredAssets: [Asset] {
        scope.filter(assets)
    }

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
        .background(Color("AppBackground").ignoresSafeArea())
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
                scopePicker
                heroSection
                breakdownSection
                staleSection
            }
            .padding()
            .animation(.spring(duration: 0.4), value: scope)
        }
    }

    private var scopePicker: some View {
        Picker("Owner", selection: scopeBinding) {
            ForEach(OwnerScope.allCases) { s in
                Text(s.displayName).tag(s)
            }
        }
        .pickerStyle(.segmented)
    }

    private var heroSection: some View {
        let nw = viewModel.netWorth(for: filteredAssets)
        let delta = viewModel.momDelta(for: filteredAssets)
        let series = viewModel.sparklineSeries(for: filteredAssets)

        return VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Net Worth")
            Text(nw.currencyUSD)
                .font(.system(size: 48, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText())
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
                summaryStat("Assets", value: viewModel.totalAssets(for: filteredAssets))
                Divider().frame(height: 32)
                summaryStat("Liabilities", value: viewModel.totalLiabilities(for: filteredAssets))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func summaryStat(_ label: String, value: Decimal) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value.compactCurrencyUSD)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var breakdownSection: some View {
        VStack(spacing: 16) {
            CategoryDonutView(title: "Assets by Category", breakdown: viewModel.assetBreakdown(for: filteredAssets))
                .cardStyle()

            let liabilities = viewModel.liabilityBreakdown(for: filteredAssets)
            if !liabilities.isEmpty {
                CategoryDonutView(title: "Liabilities by Category", breakdown: liabilities)
                    .cardStyle()
            }
        }
    }

    @ViewBuilder
    private var staleSection: some View {
        let stale = viewModel.staleAssets(filteredAssets)
        if !stale.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionLabel(text: "Needs an update for \(viewModel.month.shortLabel)")
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
        }
    }
}
