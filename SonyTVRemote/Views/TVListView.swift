import SwiftUI

struct TVListView: View {
    @ObservedObject var viewModel: TVListViewModel
    @State private var showManualEntry = false
    @State private var manualIP = ""

    var body: some View {
        List {
            // Saved TVs
            if !viewModel.savedTVs.isEmpty {
                Section("My TVs") {
                    ForEach(viewModel.savedTVs) { tv in
                        Button {
                            viewModel.select(tv)
                        } label: {
                            TVListRowView(tv: tv)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.forget(tv)
                            } label: {
                                Label("Forget", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            // Scan results
            Section {
                if viewModel.isScanning || !viewModel.discoveredTVs.isEmpty {
                    ForEach(viewModel.discoveredTVs) { tv in
                        Button {
                            viewModel.select(tv)
                        } label: {
                            TVListRowView(tv: tv)
                        }
                    }

                    if viewModel.isScanning {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 8)
                            Text("Scanning for TVs...")
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Button {
                        viewModel.startScan()
                    } label: {
                        Label("Scan for TVs", systemImage: "wifi")
                    }
                }
            } header: {
                Text("Found on Network")
            } footer: {
                if let error = viewModel.discoveryService.error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }

            // Manual entry
            Section("Manual Entry") {
                Button {
                    showManualEntry = true
                } label: {
                    Label("Add TV by IP Address", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("Sony TV Remote")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isScanning {
                    Button("Stop") {
                        viewModel.stopScan()
                    }
                } else {
                    Button {
                        viewModel.startScan()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .alert("Add TV by IP", isPresented: $showManualEntry) {
            TextField("192.168.1.x", text: $manualIP)
                .keyboardType(.numbersAndPunctuation)
            Button("Add") {
                viewModel.manualIP = manualIP
                viewModel.addManually()
                manualIP = ""
            }
            Button("Cancel", role: .cancel) {
                manualIP = ""
            }
        } message: {
            Text("Enter the IP address of your Sony TV.")
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
