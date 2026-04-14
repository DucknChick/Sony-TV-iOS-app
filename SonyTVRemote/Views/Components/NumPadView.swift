import SwiftUI

struct NumPadView: View {
    let onCommand: (IRCCCommand) -> Void

    private let rows: [[IRCCCommand?]] = [
        [.num1, .num2, .num3],
        [.num4, .num5, .num6],
        [.num7, .num8, .num9],
        [nil,   .num0, nil  ]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<rows.count, id: \.self) { rowIdx in
                HStack(spacing: 10) {
                    ForEach(0..<rows[rowIdx].count, id: \.self) { colIdx in
                        if let cmd = rows[rowIdx][colIdx] {
                            RemoteButton(label: cmd.displayName, style: .numeric) {
                                onCommand(cmd)
                            }
                        } else {
                            Spacer()
                                .frame(width: 68, height: 52)
                        }
                    }
                }
            }
        }
    }
}
