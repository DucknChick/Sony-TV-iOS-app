import SwiftUI

struct LockGateView<Content: View>: View {
    @Environment(BiometricGate.self) private var gate
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .blur(radius: gate.isUnlocked ? 0 : 20)
                .allowsHitTesting(gate.isUnlocked)

            if !gate.isUnlocked {
                lockOverlay
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: gate.isUnlocked)
    }

    private var lockOverlay: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("NestEgg")
                .font(.largeTitle.bold())
            Text(failureMessage ?? "Locked")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                Task { await gate.authenticate() }
            } label: {
                Label("Unlock", systemImage: "faceid")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isAuthenticating)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .ignoresSafeArea()
    }

    private var isAuthenticating: Bool {
        if case .authenticating = gate.state { return true }
        return false
    }

    private var failureMessage: String? {
        if case .failed(let msg) = gate.state { return msg }
        return nil
    }
}
