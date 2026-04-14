import SwiftUI

struct RootView: View {
    private let persistence: TVPersistenceService
    private let discoveryService: TVDiscoveryService
    private let pairingService: TVPairingService
    private let commandService: TVCommandService

    @StateObject private var tvListVM: TVListViewModel
    @State private var navigationPath: [SonyTV] = []

    init(
        persistence: TVPersistenceService,
        discoveryService: TVDiscoveryService,
        pairingService: TVPairingService,
        commandService: TVCommandService
    ) {
        self.persistence = persistence
        self.discoveryService = discoveryService
        self.pairingService = pairingService
        self.commandService = commandService
        _tvListVM = StateObject(wrappedValue: TVListViewModel(
            discoveryService: discoveryService,
            persistence: persistence
        ))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            TVListView(viewModel: tvListVM)
                .navigationDestination(for: SonyTV.self) { tv in
                    RemoteControlView(
                        viewModel: RemoteViewModel(
                            tv: tv,
                            commandService: commandService,
                            persistence: persistence
                        )
                    )
                }
        }
        .sheet(item: $tvListVM.tvPendingPairing) { tv in
            PairingView(
                viewModel: PairingViewModel(
                    tv: tv,
                    pairingService: pairingService,
                    persistence: persistence
                ),
                onPaired: { pairedTV in
                    tvListVM.didPair(pairedTV)
                    navigationPath.append(pairedTV)
                }
            )
        }
        .onChange(of: tvListVM.selectedTV) { _, newTV in
            if let tv = newTV {
                navigationPath.append(tv)
                tvListVM.selectedTV = nil
            }
        }
    }
}
