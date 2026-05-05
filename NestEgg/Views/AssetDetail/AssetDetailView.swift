import SwiftUI
import SwiftData
import Charts

struct AssetDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let asset: Asset
    @State private var showingValuationForm = false
    @State private var editingValuation: Valuation?
    @State private var showingAssetEdit = false
    @State private var showingDeleteConfirm = false

    private var viewModel: AssetDetailViewModel { AssetDetailViewModel(asset: asset) }

    var body: some View {
        List {
            Section { AssetMetricsHeader(viewModel: viewModel) }

            if !viewModel.chartSeries.isEmpty {
                Section("History") {
                    chart
                        .frame(height: 200)
                        .padding(.vertical, 8)
                }
            }

            Section("Monthly Values") {
                let sorted = asset.sortedValuations.reversed()
                if sorted.isEmpty {
                    Text("No values yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(sorted), id: \.id) { val in
                        Button {
                            editingValuation = val
                        } label: {
                            AssetValuationRow(valuation: val)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteValuations)
                }
            }

            if let notes = asset.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle(asset.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingValuationForm = true
                    } label: { Label("Add value", systemImage: "plus") }
                    Button {
                        showingAssetEdit = true
                    } label: { Label("Edit asset", systemImage: "pencil") }
                    Divider()
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: { Label("Delete asset", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingValuationForm) {
            NavigationStack {
                ValuationFormView(asset: asset, initialMonth: .current())
            }
        }
        .sheet(item: $editingValuation) { val in
            NavigationStack {
                ValuationFormView(asset: asset, editing: val)
            }
        }
        .sheet(isPresented: $showingAssetEdit) {
            NavigationStack {
                AssetFormView(mode: .edit(asset))
            }
        }
        .confirmationDialog(
            "Delete \(asset.name)?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                PersistenceController.deleteAsset(asset, in: context)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This permanently removes the asset and all of its monthly values.")
        }
    }

    private var chart: some View {
        let series = viewModel.chartSeries
        let isLiability = asset.isLiability
        return Chart {
            ForEach(series, id: \.month) { point in
                LineMark(
                    x: .value("Month", point.month.firstOfMonth),
                    y: .value("Amount", point.amount.doubleValue)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(isLiability ? Color.red : Color.accentColor)
                AreaMark(
                    x: .value("Month", point.month.firstOfMonth),
                    y: .value("Amount", point.amount.doubleValue)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            (isLiability ? Color.red : Color.accentColor).opacity(0.25),
                            (isLiability ? Color.red : Color.accentColor).opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }

    private func deleteValuations(at offsets: IndexSet) {
        let sorted = Array(asset.sortedValuations.reversed())
        for idx in offsets {
            let val = sorted[idx]
            PersistenceController.deleteValuation(val, in: context)
        }
    }
}
