import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(BiometricGate.self) private var gate

    @AppStorage("reminders.enabled") private var remindersEnabled = false

    @State private var exportDocument: BackupDocument?
    @State private var isExporting = false
    @State private var exportError: String?
    @State private var notificationsDenied = false

    var body: some View {
        @Bindable var gate = gate
        List {
            Section("Privacy") {
                Toggle("Lock with Face ID / passcode", isOn: $gate.isEnabled)
            }

            Section {
                Toggle("Monthly update reminder", isOn: reminderBinding)
                if notificationsDenied {
                    Label(
                        "Notifications are disabled. Enable them in Settings → NestEgg.",
                        systemImage: "bell.slash"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text("We'll send a friendly nudge on the 1st of each month at 9am.")
            }

            Section("Data") {
                NavigationLink {
                    ManageCategoriesView()
                } label: {
                    Label("Manage categories", systemImage: "folder")
                }

                NavigationLink {
                    RestoreView()
                } label: {
                    Label("Restore from backup…", systemImage: "square.and.arrow.down")
                }

                Button {
                    Haptics.tap()
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
        .task {
            let status = await ReminderService.currentAuthorizationStatus()
            notificationsDenied = (status == .denied) && remindersEnabled
            if status == .denied && remindersEnabled {
                remindersEnabled = false
                ReminderService.setMonthlyReminder(enabled: false)
            }
        }
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

    private var reminderBinding: Binding<Bool> {
        Binding(
            get: { remindersEnabled },
            set: { newValue in
                if newValue {
                    Task {
                        let granted = await ReminderService.requestAuthorization()
                        await MainActor.run {
                            if granted {
                                remindersEnabled = true
                                notificationsDenied = false
                                ReminderService.setMonthlyReminder(enabled: true)
                                Haptics.success()
                            } else {
                                remindersEnabled = false
                                notificationsDenied = true
                                Haptics.warning()
                            }
                        }
                    }
                } else {
                    remindersEnabled = false
                    notificationsDenied = false
                    ReminderService.setMonthlyReminder(enabled: false)
                    Haptics.tap()
                }
            }
        )
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
