import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label("Dashboard", systemImage: "chart.pie.fill") }

            NavigationStack { AssetsListView() }
                .tabItem { Label("Assets", systemImage: "list.bullet.rectangle") }

            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(Color.accentColor)
    }
}
