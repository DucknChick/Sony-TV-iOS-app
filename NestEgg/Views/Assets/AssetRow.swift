import SwiftUI

struct AssetRow: View {
    let asset: Asset
    private let thisMonth = MonthKey.current()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.body)
                HStack(spacing: 6) {
                    OwnerChip(owner: asset.owner)
                    if let inst = asset.institution, !inst.isEmpty {
                        Text(inst)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(currentValue.compactCurrencyUSD)
                    .monospacedDigit()
                if let delta = monthOverMonth {
                    DeltaBadge(amount: delta.absolute, percent: delta.percent, showAmount: false)
                }
            }
        }
        .contentShape(Rectangle())
    }

    private var currentValue: Decimal {
        NetWorthAggregator.currentValue(of: asset, at: thisMonth)
    }

    private var monthOverMonth: NetWorthAggregator.Delta? {
        let now = NetWorthAggregator.currentValue(of: asset, at: thisMonth)
        let prev = NetWorthAggregator.currentValue(of: asset, at: thisMonth.adding(months: -1))
        guard prev != 0 else { return nil }
        let delta = now - prev
        let pctBase = prev < 0 ? -prev : prev
        return NetWorthAggregator.Delta(absolute: delta, percent: delta / pctBase)
    }
}

struct OwnerChip: View {
    let owner: Owner

    var body: some View {
        Text(owner.displayName)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.accentColor.opacity(0.15))
            .foregroundStyle(Color.accentColor)
            .clipShape(Capsule())
    }
}
