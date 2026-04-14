import SwiftUI

struct MediaControlsView: View {
    let onCommand: (IRCCCommand) -> Void

    private let buttons: [(IRCCCommand, String)] = [
        (.rewind,  "backward.fill"),
        (.play,    "play.fill"),
        (.pause,   "pause.fill"),
        (.stop,    "stop.fill"),
        (.forward, "forward.fill")
    ]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(buttons, id: \.0) { (command, image) in
                RemoteButton(systemImage: image, style: .media) {
                    onCommand(command)
                }
            }
        }
    }
}
