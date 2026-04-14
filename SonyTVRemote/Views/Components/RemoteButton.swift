import SwiftUI

enum RemoteButtonStyle {
    case standard, power, numeric, media, navigation
}

struct RemoteButton: View {
    var systemImage: String? = nil
    var label: String? = nil
    var style: RemoteButtonStyle = .standard
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(iconFont)
                } else if let label {
                    Text(label)
                        .font(labelFont)
                        .minimumScaleFactor(0.5)
                }
            }
            .frame(width: buttonSize.width, height: buttonSize.height)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var buttonSize: CGSize {
        switch style {
        case .power:      return CGSize(width: 56, height: 56)
        case .numeric:    return CGSize(width: 68, height: 52)
        case .media:      return CGSize(width: 56, height: 44)
        case .navigation: return CGSize(width: 64, height: 44)
        case .standard:   return CGSize(width: 64, height: 52)
        }
    }

    private var cornerRadius: CGFloat {
        style == .power ? 28 : 12
    }

    private var backgroundColor: Color {
        switch style {
        case .power:   return Color(.systemRed).opacity(0.15)
        case .numeric: return Color(.secondarySystemBackground)
        default:       return Color(.secondarySystemBackground)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .power: return .red
        default:     return .primary
        }
    }

    private var borderColor: Color {
        Color(.separator).opacity(0.5)
    }

    private var iconFont: Font {
        switch style {
        case .power:      return .system(size: 22, weight: .medium)
        case .media:      return .system(size: 18, weight: .medium)
        case .navigation: return .system(size: 16, weight: .medium)
        default:          return .system(size: 18, weight: .medium)
        }
    }

    private var labelFont: Font {
        switch style {
        case .numeric: return .system(size: 20, weight: .semibold, design: .rounded)
        default:       return .system(size: 14, weight: .medium)
        }
    }
}

// Press-scale animation
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
