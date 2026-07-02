import SwiftUI

struct PairingView: View {
    @ObservedObject var viewModel: PairingViewModel
    let onPaired: (SonyTV) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Icon
                Image(systemName: "tv.badge.wifi")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)

                // Instructions
                VStack(spacing: 8) {
                    Text("Pair with \(viewModel.tv.name)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text("A PIN is displayed on your TV screen.\nEnter it below to connect.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // PIN field
                VStack(spacing: 12) {
                    TextField("PIN", text: $viewModel.pin)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 160)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .onChange(of: viewModel.pin) { _, newValue in
                            // Limit to 4 digits
                            viewModel.pin = String(newValue.filter { $0.isNumber }.prefix(4))
                        }

                    if let errorMsg = viewModel.pairingState.errorMessage {
                        Text(errorMsg)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }

                // Actions
                VStack(spacing: 12) {
                    if viewModel.pairingState == .verifying {
                        ProgressView("Verifying...")
                    } else {
                        Button {
                            Task {
                                if let pairedTV = await viewModel.confirmPin() {
                                    onPaired(pairedTV)
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Connect")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.canConfirm ? Color.accentColor : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(!viewModel.canConfirm)
                    }

                    Button("Cancel") { dismiss() }
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .toolbar(.hidden, for: .navigationBar)
        }
        .task {
            await viewModel.startPairing()
        }
    }
}
