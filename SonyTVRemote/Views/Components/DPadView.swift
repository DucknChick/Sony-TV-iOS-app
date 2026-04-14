import SwiftUI

struct DPadView: View {
    let onCommand: (IRCCCommand) -> Void

    var body: some View {
        ZStack {
            // Cross arms
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.tvBtn)
                .frame(width: 186, height: 58)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tvBorder, lineWidth: 0.5))

            RoundedRectangle(cornerRadius: 14)
                .fill(Color.tvBtn)
                .frame(width: 58, height: 186)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tvBorder, lineWidth: 0.5))

            // Buttons
            VStack(spacing: 0) {
                arrowButton(.up, image: "chevron.up")
                HStack(spacing: 0) {
                    arrowButton(.left,  image: "chevron.left")
                    okButton
                    arrowButton(.right, image: "chevron.right")
                }
                arrowButton(.down, image: "chevron.down")
            }
        }
    }

    private func arrowButton(_ command: IRCCCommand, image: String) -> some View {
        Button { onCommand(command) } label: {
            Image(systemName: image)
                .font(.system(size: 17, weight: .semibold))
                .frame(width: 58, height: 58)
                .foregroundColor(.white)
                .contentShape(Rectangle())
        }
        .buttonStyle(DPadPressStyle())
    }

    private var okButton: some View {
        Button { onCommand(.confirm) } label: {
            Text("OK")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .frame(width: 70, height: 70)
                .foregroundColor(.white)
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(color: Color.accentColor.opacity(0.4), radius: 8, x: 0, y: 0)
        }
        .buttonStyle(DPadPressStyle())
    }
}

private struct DPadPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .opacity(configuration.isPressed ? 0.75 : 1.0)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}
