import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(BiometricGate.self) private var gate

    @State private var exportDocument: BackupDocument?
    @State private var isExporting = false
    @State private var exportError: String?

    var body: some View {
        @Bindable var gate = gate
        List {
            Section("Privacy") {
                Toggle("Lock with Face ID / passcode", isOn: $gate.isEnabled)
            }

            Section("Data") {
                NavigationLink {
                    ManageCategoriesView()
                } label: {
                    Label("Manage categories", systemImage: "folder")
                }

                Button {
                    prepareExport()
                } label: {
                    Label("Export data (JSON)", systemImage: "square.and.arrow.up")
                }
            }

            Section("Danger Zone") {
                NavigationLink {
                    ResetDataView()
                } label: {
                    Label("Reset all data…", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(versionString)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "nestegg-backup-\(MonthKey.current().description)"
        ) { result in
            if case .failure(let error) = result {
                exportError = error.localizedDescription
            }
        }
        .alert("Export failed", isPresented: .constant(exportError != nil)) {
            Button("OK") { exportError = nil }
        } message: {
            Text(exportError ?? "")
        }
    }

    private var versionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    private func prepareExport() {
        do {
            let data = try ExportService.makeBackupData(in: context)
            exportDocument = BackupDocument(data: data)
            isExporting = true
        } catch {
            exportError = error.localizedDescription
        }
    }
}
