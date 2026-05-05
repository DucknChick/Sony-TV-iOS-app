import SwiftUI
import SwiftData

struct AssetFormView: View {
    enum Mode {
        case create
        case edit(Asset)
    }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Category.sortOrder)]) private var categories: [Category]

    let mode: Mode

    @State private var name = ""
    @State private var institution = ""
    @State private var notes = ""
    @State private var owner: Owner = .joint
    @State private var selectedCategory: Category?
    @State private var hasPurchaseDate = false
    @State private var purchaseDate: Date = .now
    @State private var costBasisString = ""
    @State private var initialMonth: MonthKey = .current()
    @State private var initialAmountString = ""
    @State private var didLoad = false

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var existingAsset: Asset? {
        if case .edit(let a) = mode { return a }
        return nil
    }

    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                TextField("Institution (optional)", text: $institution)
                Picker("Category", selection: $selectedCategory) {
                    Text("Select…").tag(Category?.none)
                    ForEach(categories) { cat in
                        Text(cat.name).tag(Optional(cat))
                    }
                }
                Picker("Owner", selection: $owner) {
                    ForEach(Owner.allCases) { o in
                        Text(o.displayName).tag(o)
                    }
                }
            }

            if selectedCategory?.tracksCostBasis == true {
                Section("Cost Basis") {
                    Toggle("Has purchase date", isOn: $hasPurchaseDate)
                    if hasPurchaseDate {
                        DatePicker("Purchase date", selection: $purchaseDate, displayedComponents: .date)
                    }
                    TextField("Cost basis (USD)", text: $costBasisString)
                        .keyboardType(.decimalPad)
                }
            }

            if !isEditing {
                Section("Initial Value") {
                    MonthPickerView(selection: $initialMonth)
                    TextField("Amount (USD)", text: $initialAmountString)
                        .keyboardType(.decimalPad)
                }
            }

            if !notes.isEmpty || isEditing {
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...6)
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Asset" : "New Asset")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { save() }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
            }
        }
        .onAppear(perform: loadIfNeeded)
    }

    private var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard selectedCategory != nil else { return false }
        return true
    }

    private func loadIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        if case .edit(let a) = mode {
            name = a.name
            institution = a.institution ?? ""
            notes = a.notes ?? ""
            owner = a.owner
            selectedCategory = a.category
            if let d = a.purchaseDate {
                hasPurchaseDate = true
                purchaseDate = d
            }
            if let cb = a.costBasis {
                costBasisString = NSDecimalNumber(decimal: cb).stringValue
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let inst = institution.trimmingCharacters(in: .whitespaces).nilIfEmpty
        let notesTrim = notes.trimmingCharacters(in: .whitespaces).nilIfEmpty
        let costBasis: Decimal? = {
            guard selectedCategory?.tracksCostBasis == true else { return nil }
            return Decimal(string: costBasisString.trimmingCharacters(in: .whitespaces))
        }()
        let purchase: Date? = (selectedCategory?.tracksCostBasis == true && hasPurchaseDate) ? purchaseDate : nil

        switch mode {
        case .create:
            let asset = Asset(
                name: trimmedName,
                category: selectedCategory,
                institution: inst,
                notes: notesTrim,
                purchaseDate: purchase,
                costBasis: costBasis,
                owner: owner
            )
            context.insert(asset)
            try? context.save()
            if let amount = Decimal(string: initialAmountString.trimmingCharacters(in: .whitespaces)),
               amount != 0 {
                PersistenceController.upsertValuation(
                    amount: amount,
                    month: initialMonth,
                    asset: asset,
                    in: context
                )
            }

        case .edit(let asset):
            asset.name = trimmedName
            asset.institution = inst
            asset.notes = notesTrim
            asset.owner = owner
            asset.category = selectedCategory
            asset.purchaseDate = purchase
            asset.costBasis = costBasis
            try? context.save()
        }
        dismiss()
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
