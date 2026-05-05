import SwiftUI
import SwiftData

struct ManageCategoriesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Category.sortOrder)]) private var categories: [Category]

    @State private var showingNew = false
    @State private var newName = ""
    @State private var newIsLiability = false
    @State private var newTracksCostBasis = true

    var body: some View {
        List {
            Section("Built-in") {
                ForEach(categories.filter { $0.isBuiltIn }) { cat in
                    HStack {
                        Text(cat.name)
                        Spacer()
                        Text(cat.isLiability ? "Liability" : "Asset")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            let custom = categories.filter { !$0.isBuiltIn }
            if !custom.isEmpty {
                Section("Custom") {
                    ForEach(custom) { cat in
                        HStack {
                            Text(cat.name)
                            Spacer()
                            Text(cat.isLiability ? "Liability" : "Asset")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteCustom)
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNew = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNew) {
            NavigationStack {
                Form {
                    TextField("Name", text: $newName)
                    Toggle("Is liability", isOn: $newIsLiability)
                    if !newIsLiability {
                        Toggle("Tracks cost basis (gain/loss)", isOn: $newTracksCostBasis)
                    }
                }
                .navigationTitle("New Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            resetNewForm()
                            showingNew = false
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") { saveNew() }
                            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    private func saveNew() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let nextOrder = (categories.map(\.sortOrder).max() ?? 0) + 10
        let cat = Category(
            name: trimmed,
            isLiability: newIsLiability,
            sortOrder: nextOrder,
            isBuiltIn: false,
            tracksCostBasis: newIsLiability ? false : newTracksCostBasis
        )
        context.insert(cat)
        try? context.save()
        resetNewForm()
        showingNew = false
    }

    private func resetNewForm() {
        newName = ""
        newIsLiability = false
        newTracksCostBasis = true
    }

    private func deleteCustom(at offsets: IndexSet) {
        let custom = categories.filter { !$0.isBuiltIn }
        for idx in offsets {
            let cat = custom[idx]
            // Refuse if any assets still reference this category.
            if cat.assets.contains(where: { !$0.isArchived }) { continue }
            context.delete(cat)
        }
        try? context.save()
    }
}
