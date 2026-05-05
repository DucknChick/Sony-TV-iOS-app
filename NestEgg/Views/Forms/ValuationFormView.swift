import SwiftUI
import SwiftData

struct ValuationFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let asset: Asset
    private let editing: Valuation?
    @State private var month: MonthKey
    @State private var amountString: String
    @State private var didLoad = false

    init(asset: Asset, initialMonth: MonthKey) {
        self.asset = asset
        self.editing = nil
        self._month = State(initialValue: initialMonth)
        let existing = asset.valuation(for: initialMonth)
        self._amountString = State(
            initialValue: existing.map { NSDecimalNumber(decimal: $0.amount).stringValue } ?? ""
        )
    }

    init(asset: Asset, editing: Valuation) {
        self.asset = asset
        self.editing = editing
        self._month = State(initialValue: MonthKey(rawValue: editing.monthKey))
        self._amountString = State(initialValue: NSDecimalNumber(decimal: editing.amount).stringValue)
    }

    var body: some View {
        Form {
            Section("Month") {
                if editing == nil {
                    MonthPickerView(selection: $month)
                } else {
                    Text(month.shortLabel)
                        .foregroundStyle(.secondary)
                }
            }
            Section(asset.isLiability ? "Outstanding Balance" : "Value") {
                TextField("Amount (USD)", text: $amountString)
                    .keyboardType(.decimalPad)
            }
            if editing == nil, asset.valuation(for: month) != nil {
                Section {
                    Label(
                        "A value already exists for \(month.shortLabel) — saving will replace it.",
                        systemImage: "info.circle"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            if let editing {
                Section {
                    Button("Delete value", role: .destructive) {
                        PersistenceController.deleteValuation(editing, in: context)
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(editing == nil ? "Add Value" : "Edit Value")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(saveLabel) { save() }
                    .disabled(parsedAmount == nil)
                    .fontWeight(.semibold)
            }
        }
    }

    private var saveLabel: String {
        if editing != nil { return "Save" }
        return asset.valuation(for: month) != nil ? "Replace" : "Save"
    }

    private var parsedAmount: Decimal? {
        Decimal(string: amountString.trimmingCharacters(in: .whitespaces))
    }

    private func save() {
        guard let amount = parsedAmount else { return }
        if let editing {
            editing.amount = amount
            editing.recordedAt = .now
            try? context.save()
        } else {
            PersistenceController.upsertValuation(
                amount: amount,
                month: month,
                asset: asset,
                in: context
            )
        }
        dismiss()
    }
}
