import SwiftUI

struct TVListRowView: View {
    let tv: SonyTV

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "tv.fill")
                .font(.title2)
                .foregroundColor(tv.isPaired ? .accentColor : .secondary)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(tv.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text(tv.ipAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if tv.isPaired {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Text("Tap to pair")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
