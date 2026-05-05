import SwiftUI
import SwiftData

struct AssetsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Asset.name)]) private var assets: [Asset]
    @Query(sort: [SortDescriptor(\Category.sortOrder)]) private var categories: [Category]

    @State private var showingNewAsset = false

    var body: some View {
        Group {
            if assets.isEmpty {
                EmptyStateView(
                    systemImage: "list.bullet.rectangle",
                    title: "No assets yet",
                    message: "Track investments, cash, real estate, and more.",
                    actionTitle: "Add asset"
                ) { showingNewAsset = true }
            } else {
                List {
                    ForEach(assetCategories) { cat in
                        categorySection(cat, liabilities: false)
                    }
                    ForEach(liabilityCategories) { cat in
                        categorySection(cat, liabilities: true)
                    }
                }
            }
        }
        .navigationTitle("Assets")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewAsset = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewAsset) {
            NavigationStack {
                AssetFormView(mode: .create)
            }
        }
    }

    private var assetCategories: [Category] {
        categories.filter { !$0.isLiability && hasAssets(in: $0) }
    }

    private var liabilityCategories: [Category] {
        categories.filter { $0.isLiability && hasAssets(in: $0) }
    }

    private func hasAssets(in category: Category) -> Bool {
        assets.contains { $0.category?.name == category.name && !$0.isArchived }
    }

    private func assetsIn(_ category: Category) -> [Asset] {
        assets.filter { $0.category?.name == category.name && !$0.isArchived }
    }

    @ViewBuilder
    private func categorySection(_ category: Category, liabilities: Bool) -> some View {
        let inCat = assetsIn(category)
        if !inCat.isEmpty {
            Section(category.name) {
                ForEach(inCat) { asset in
                    NavigationLink {
                        AssetDetailView(asset: asset)
                    } label: {
                        AssetRow(asset: asset)
                    }
                }
            }
        }
    }
}
