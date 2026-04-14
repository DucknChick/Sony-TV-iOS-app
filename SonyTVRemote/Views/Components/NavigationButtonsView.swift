import SwiftUI

struct NavigationButtonsView: View {
    let onCommand: (IRCCCommand) -> Void

    private let buttons: [(IRCCCommand, String, String)] = [
        (.home,    "house.fill",       "Home"),
        (.back,    "arrow.uturn.left", "Back"),
        (.menu,    "list.bullet",      "Menu"),
        (.options, "ellipsis",         "Options")
    ]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(buttons, id: \.0) { (command, image, label) in
                VStack(spacing: 4) {
                    RemoteButton(systemImage: image, style: .navigation) {
                        onCommand(command)
                    }
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
