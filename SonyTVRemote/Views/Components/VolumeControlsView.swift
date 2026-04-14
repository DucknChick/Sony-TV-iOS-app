import SwiftUI

struct VolumeControlsView: View {
    let onCommand: (IRCCCommand) -> Void

    var body: some View {
        HStack(spacing: 16) {
            RemoteButton(systemImage: "speaker.minus.fill", style: .standard) {
                onCommand(.volumeDown)
            }
            RemoteButton(systemImage: "speaker.slash.fill", style: .standard) {
                onCommand(.mute)
            }
            RemoteButton(systemImage: "speaker.plus.fill", style: .standard) {
                onCommand(.volumeUp)
            }
        }
    }
}
