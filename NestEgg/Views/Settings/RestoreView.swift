import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct RestoreView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var isPickerShown = false
    @State private var pendingBackup: BackupV1?
    @State private var pendingCounts: ImportService.Counts?
    @State private var pendingFilename: String?
    @State private var errorMessage: String?
    @State private var showSuccess = false

    var body: some View {
        Form {
            Section {
                Text("Restoring replaces all current data with the contents of a NestEgg backup file. Make sure to export your current data first if you want to keep it.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    Haptics.tap()
                    isPickerShown = true
                } label: {
                    Label("Choose backup file…", systemImage: "doc.badge.arrow.up")
                }
            }

            if let counts = pendingCounts, let filename = pendingFilename {
                Section("Preview") {
                    LabeledContent("File", value: filename)
                    LabeledContent("Categories", value: "\(counts.categories)")
                    LabeledContent("Assets", value: "\(counts.assets)")
                    LabeledContent("Valuations", value: "\(counts.valuations)")
                }

                Section {
                    Button(role: .destructive) {
                        confirmReplace()
                    } label: {
                        Label("Replace all data", systemImage: "arrow.triangle.2.circlepath")
                    }
                } footer: {
                    Text("This will permanently overwrite the data currently on this device.")
                }
            }
        }
        .navigationTitle("Restore from backup")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $isPickerShown,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handlePicker(result)
        }
        .alert("Restore failed", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .alert("Data restored", isPresented: $showSuccess) {
            Button("Done") { dismiss() }
        } message: {
            Text("Your backup has been imported successfully.")
        }
    }

    private func handlePicker(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let err):
            errorMessage = err.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            let needsScopedAccess = url.startAccessingSecurityScopedResource()
            defer {
                if needsScopedAccess { url.stopAccessingSecurityScopedResource() }
            }
            do {
                let data = try Data(contentsOf: url)
                let backup = try ImportService.decode(data)
                pendingBackup = backup
                pendingCounts = ImportService.counts(of: backup)
                pendingFilename = url.lastPathComponent
            } catch {
                errorMessage = error.localizedDescription
                pendingBackup = nil
                pendingCounts = nil
                pendingFilename = nil
            }
        }
    }

    private func confirmReplace() {
        guard let backup = pendingBackup else { return }
        do {
            try PersistenceController.replaceAllData(with: backup, in: context)
            Haptics.success()
            pendingBackup = nil
            pendingCounts = nil
            pendingFilename = nil
            showSuccess = true
        } catch {
            Haptics.warning()
            errorMessage = error.localizedDescription
        }
    }
}
