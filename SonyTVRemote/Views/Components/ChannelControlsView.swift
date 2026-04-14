import SwiftUI

struct ChannelControlsView: View {
    let onCommand: (IRCCCommand) -> Void

    var body: some View {
        HStack(spacing: 16) {
            RemoteButton(systemImage: "minus", label: "CH", style: .standard) {
                onCommand(.channelDown)
            }
            RemoteButton(label: "CH", style: .standard) {
                // no-op label cell
            }
            .disabled(true)
            .opacity(0)
            RemoteButton(systemImage: "plus", label: "CH", style: .standard) {
                onCommand(.channelUp)
            }
        }
    }
}
