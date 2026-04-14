import SwiftUI

struct RemoteControlView: View {
    @ObservedObject var viewModel: RemoteViewModel
    @State private var showInputPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Power row
                powerRow

                Divider()

                // Volume
                sectionLabel("Volume")
                VolumeControlsView(onCommand: viewModel.tap)

                Divider()

                // Channel
                channelRow

                Divider()

                // Navigation buttons
                sectionLabel("Navigation")
                NavigationButtonsView(onCommand: viewModel.tap)

                Divider()

                // D-Pad
                DPadView(onCommand: viewModel.tap)

                Divider()

                // Media controls
                sectionLabel("Media")
                MediaControlsView(onCommand: viewModel.tap)

                Divider()

                // Number pad
                sectionLabel("Keypad")
                NumPadView(onCommand: viewModel.tap)

                Divider()

                // Input selector
                inputSection

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .navigationTitle(viewModel.tv.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: Binding(
            get: { viewModel.lastError != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.lastError ?? "")
        }
        .sheet(isPresented: $showInputPicker) {
            InputPickerView(inputs: viewModel.availableInputs) { input in
                viewModel.selectInput(input)
                showInputPicker = false
            }
        }
        .onAppear {
            viewModel.loadInputList()
        }
    }

    private var powerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Power")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 12) {
                    RemoteButton(systemImage: "power", style: .power) {
                        viewModel.powerOff()
                    }
                    RemoteButton(systemImage: "wake.display", style: .standard) {
                        viewModel.powerOn()
                    }
                    .help("Wake on LAN / Power On")
                }
            }
            Spacer()
        }
    }

    private var channelRow: some View {
        HStack {
            sectionLabel("Channel")
            Spacer()
            HStack(spacing: 12) {
                RemoteButton(systemImage: "chevron.down", style: .standard) {
                    viewModel.tap(.channelDown)
                }
                RemoteButton(systemImage: "chevron.up", style: .standard) {
                    viewModel.tap(.channelUp)
                }
            }
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Input Source")
            Button {
                showInputPicker = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.connected.to.line.below")
                    Text("Select Input")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            .foregroundColor(.primary)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

// MARK: - Input Picker Sheet

private struct InputPickerView: View {
    let inputs: [TVInput]
    let onSelect: (TVInput) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if inputs.isEmpty {
                    ContentUnavailableView(
                        "No Inputs Found",
                        systemImage: "rectangle.connected.to.line.below",
                        description: Text("Could not retrieve input list from TV.")
                    )
                } else {
                    List(inputs) { input in
                        Button {
                            onSelect(input)
                        } label: {
                            Text(input.title)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Select Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
