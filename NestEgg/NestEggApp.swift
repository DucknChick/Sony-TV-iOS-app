import SwiftUI
import SwiftData

@main
struct NestEggApp: App {
    @State private var biometricGate = BiometricGate()
    @Environment(\.scenePhase) private var scenePhase
    @State private var previousPhase: ScenePhase = .active

    let modelContainer: ModelContainer

    init() {
        let container = PersistenceController.makeContainer()
        self.modelContainer = container
        let context = ModelContext(container)
        SeedService.seedIfNeeded(in: context)
    }

    var body: some Scene {
        WindowGroup {
            LockGateView {
                RootView()
            }
            .environment(biometricGate)
            .task {
                if biometricGate.isEnabled {
                    await biometricGate.authenticate()
                }
            }
            .onChange(of: scenePhase) { old, new in
                handleScenePhase(old: old, new: new)
            }
        }
        .modelContainer(modelContainer)
    }

    private func handleScenePhase(old: ScenePhase, new: ScenePhase) {
        // Lock when leaving the foreground entirely.
        if new == .background {
            biometricGate.lock()
        }
        // Re-prompt only on background -> active. Ignore inactive transitions
        // (control center, notification center, system alerts) to avoid spurious prompts.
        if previousPhase == .background, new == .active {
            Task { await biometricGate.authenticate() }
        }
        previousPhase = new
    }
}
