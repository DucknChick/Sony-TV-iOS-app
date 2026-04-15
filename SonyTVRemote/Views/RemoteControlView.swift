import SwiftUI

// MARK: - Remote Control View (Option A — Dark Command Center)

struct RemoteControlView: View {
    @ObservedObject var viewModel: RemoteViewModel
    @State private var showNumPad = false
    @State private var showInputPicker = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.tvBg.ignoresSafeArea()

            VStack(spacing: 10) {
                navBar
                navRow
                Spacer(minLength: 4)
                centralZone
                Spacer(minLength: 4)
                mediaStrip
                bottomChips
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Error", isPresented: Binding(
            get: { viewModel.lastError != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.lastError ?? "")
        }
        .sheet(isPresented: $showNumPad) {
            NumPadSheet(onCommand: viewModel.tap)
        }
        .sheet(isPresented: $showInputPicker) {
            InputPickerSheet(inputs: viewModel.availableInputs) { input in
                viewModel.selectInput(input)
                showInputPicker = false
            }
        }
        .onAppear {
            viewModel.loadInputList()
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack(spacing: 8) {
            // Back
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .foregroundColor(Color.tvSecondary)
                    .background(Color.tvBtn)
                    .clipShape(Circle())
            }
            .pressScale()

            Text(viewModel.tv.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.tvSecondary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            // Wake / Power On
            Button { viewModel.powerOn() } label: {
                Image(systemName: "wake.display")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 36, height: 36)
                    .foregroundColor(.orange)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Circle())
            }
            .pressScale()

            // Power Off
            Button { viewModel.powerOff() } label: {
                Image(systemName: "power")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 40, height: 40)
                    .foregroundColor(.red)
                    .background(Color.red.opacity(0.15))
                    .clipShape(Circle())
            }
            .pressScale()
        }
    }

    // MARK: - Navigation Row

    private var navRow: some View {
        HStack(spacing: 8) {
            navChip("house.fill",       "Home",    Color.tvSecondary) { viewModel.tap(.home) }
            navChip("arrow.uturn.left", "Back",    Color.tvSecondary) { viewModel.tap(.back) }
            navChip("list.bullet",      "Menu",    Color.tvSecondary) { viewModel.tap(.menu) }
            navChip("ellipsis",         "Options", Color.tvSecondary) { viewModel.tap(.options) }
        }
        .padding(8)
        .background(Color.tvCard)
        .cornerRadius(16)
    }

    private func navChip(_ icon: String, _ label: String, _ tint: Color,
                         action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(tint)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.tvBtn)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tvBorder, lineWidth: 0.5))
        }
        .pressScale()
    }

    // MARK: - Central Zone

    private var centralZone: some View {
        HStack(alignment: .center, spacing: 10) {
            // Volume column (left)
            VStack(spacing: 8) {
                sideChip("VOL +", "speaker.plus.fill",  .green)         { viewModel.tap(.volumeUp) }
                sideChip("VOL −", "speaker.minus.fill", Color(red: 0.4, green: 0.6, blue: 1)) { viewModel.tap(.volumeDown) }
                sideChip("MUTE",  "speaker.slash.fill", Color.tvSecondary) { viewModel.tap(.mute) }
            }
            .frame(width: 62)

            // D-Pad (centre)
            DPadView(onCommand: viewModel.tap)
                .frame(maxWidth: .infinity)

            // Channel column (right)
            VStack(spacing: 8) {
                sideChip("CH +", "chevron.up",   Color.tvSecondary) { viewModel.tap(.channelUp) }
                Spacer()
                sideChip("CH −", "chevron.down", Color.tvSecondary) { viewModel.tap(.channelDown) }
            }
            .frame(width: 62)
        }
        .padding(12)
        .background(Color.tvCard)
        .cornerRadius(18)
    }

    private func sideChip(_ label: String, _ icon: String, _ tint: Color,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                Text(label)
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundColor(tint)
            .frame(maxWidth: .infinity)
            .frame(height: 66)
            .background(Color.tvBtn)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tvBorder, lineWidth: 0.5))
        }
        .pressScale()
    }

    // MARK: - Media Strip

    private var mediaStrip: some View {
        HStack(spacing: 8) {
            mediaChip("backward.fill") { viewModel.tap(.rewind) }
            mediaChip("play.fill")     { viewModel.tap(.play) }
            mediaChip("pause.fill")    { viewModel.tap(.pause) }
            mediaChip("forward.fill")  { viewModel.tap(.forward) }
        }
        .padding(8)
        .background(Color.tvCard)
        .cornerRadius(14)
    }

    private func mediaChip(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.tvBtn)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tvBorder, lineWidth: 0.5))
        }
        .pressScale()
    }

    // MARK: - Bottom Chips

    private var bottomChips: some View {
        HStack(spacing: 10) {
            Button { showNumPad = true } label: {
                Label("123  Keys", systemImage: "number")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.tvSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.tvBtn)
                    .cornerRadius(13)
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.tvBorder, lineWidth: 0.5))
            }
            .pressScale()

            Button { showInputPicker = true } label: {
                Label("Input", systemImage: "rectangle.connected.to.line.below")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.tvSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.tvBtn)
                    .cornerRadius(13)
                    .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.tvBorder, lineWidth: 0.5))
            }
            .pressScale()
        }
    }
}

// MARK: - Press Scale Modifier

private extension View {
    func pressScale() -> some View {
        buttonStyle(PressScaleStyle())
    }
}

private struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.91 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Num Pad Sheet

private struct NumPadSheet: View {
    let onCommand: (IRCCCommand) -> Void
    @Environment(\.dismiss) private var dismiss

    private let rows: [[IRCCCommand?]] = [
        [.num1, .num2, .num3],
        [.num4, .num5, .num6],
        [.num7, .num8, .num9],
        [nil,   .num0, nil  ]
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tvBg.ignoresSafeArea()
                VStack(spacing: 12) {
                    ForEach(0..<rows.count, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(0..<rows[row].count, id: \.self) { col in
                                if let cmd = rows[row][col] {
                                    Button { onCommand(cmd) } label: {
                                        Text(cmd.displayName)
                                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 68)
                                            .background(Color.tvBtn)
                                            .cornerRadius(14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.tvBorder, lineWidth: 0.5)
                                            )
                                    }
                                    .buttonStyle(PressScaleStyle())
                                } else {
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 68)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Keypad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Input Picker Sheet

private struct InputPickerSheet: View {
    let inputs: [TVInput]
    let onSelect: (TVInput) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if inputs.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "rectangle.connected.to.line.below")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Inputs Found")
                            .font(.headline)
                        Text("Could not retrieve input list from TV.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
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
