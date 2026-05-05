import SwiftUI
import SwiftData

struct ResetDataView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var confirmText = ""

    private let phrase = "RESET"

    var body: some View {
        Form {
            Section {
                Label(
                    "This deletes every asset, valuation, and custom category. Default categories will be re-created.",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .foregroundStyle(.red)
            }
            Section("Type \(phrase) to confirm") {
                TextField(phrase, text: $confirmText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.characters)
            }
            Section {
                Button("Reset all data", role: .destructive) {
                    PersistenceController.resetAllData(in: context)
                    dismiss()
                }
                .disabled(confirmText != phrase)
            }
        }
        .navigationTitle("Reset Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}
