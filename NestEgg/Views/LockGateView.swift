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
        .animation(.easeInOut(duration: 0.25), value: gate.isUnlocked)
    }

    private var lockOverlay: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.15))
                        .frame(width: 96, height: 96)
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 44, weight: .regular))
                        .foregroundStyle(Color.accentColor)
                }
                VStack(spacing: 6) {
                    Text("NestEgg")
                        .font(.system(.largeTitle, design: .serif).weight(.semibold))
                    Text(failureMessage ?? "Locked")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Button {
                    Haptics.tap()
                    Task { await gate.authenticate() }
                } label: {
                    Label("Unlock", systemImage: "faceid")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isAuthenticating)
            }
            .cardStyle(padding: 28)
            .padding(.horizontal, 32)
            .transition(.scale(scale: 0.96).combined(with: .opacity))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
