import SwiftUI

struct DPadView: View {
    let onCommand: (IRCCCommand) -> Void

    var body: some View {
        ZStack {
            // Cross background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 200, height: 64)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 64, height: 200)

            // Directional buttons
            VStack(spacing: 0) {
                arrowButton(.up, image: "chevron.up")
                HStack(spacing: 0) {
                    arrowButton(.left, image: "chevron.left")
                    okButton
                    arrowButton(.right, image: "chevron.right")
                }
                arrowButton(.down, image: "chevron.down")
            }
        }
    }

    private func arrowButton(_ command: IRCCCommand, image: String) -> some View {
        Button {
            onCommand(command)
        } label: {
            Image(systemName: image)
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 64, height: 64)
                .foregroundColor(.primary)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var okButton: some View {
        Button {
            onCommand(.confirm)
        } label: {
            Text("OK")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .frame(width: 72, height: 72)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .clipShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
