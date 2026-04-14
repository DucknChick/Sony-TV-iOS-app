import Foundation
import SwiftUI

@MainActor
final class TVListViewModel: ObservableObject {
    @Published var savedTVs: [SonyTV] = []
    @Published var isScanning: Bool = false
    @Published var scanError: String?
    @Published var selectedTV: SonyTV?
    @Published var tvPendingPairing: SonyTV?
    @Published var showManualEntry: Bool = false
    @Published var manualIP: String = ""

    let discoveryService: TVDiscoveryService
    private let persistence: TVPersistenceService

    var discoveredTVs: [SonyTV] {
        discoveryService.discoveredTVs.filter { discovered in
            !savedTVs.contains(where: { $0.ipAddress == discovered.ipAddress })
        }
    }

    init(discoveryService: TVDiscoveryService, persistence: TVPersistenceService) {
        self.discoveryService = discoveryService
        self.persistence = persistence
    }

    func onAppear() {
        savedTVs = persistence.loadTVs()
    }

    func startScan() {
        scanError = nil
        discoveryService.startScan()
    }

    func stopScan() {
        discoveryService.stopScan()
    }

    func select(_ tv: SonyTV) {
        if tv.isPaired {
            selectedTV = tv
        } else {
            tvPendingPairing = tv
        }
    }

    func didPair(_ tv: SonyTV) {
        persistence.addOrUpdate(tv)
        savedTVs = persistence.loadTVs()
        tvPendingPairing = nil
        selectedTV = tv
    }

    func forget(_ tv: SonyTV) {
        persistence.remove(id: tv.id)
        savedTVs = persistence.loadTVs()
        if selectedTV?.id == tv.id { selectedTV = nil }
    }

    func addManually() {
        guard !manualIP.isEmpty else { return }
        let tv = discoveryService.addManually(ipAddress: manualIP)
        manualIP = ""
        showManualEntry = false
        select(tv)
    }

    func refreshSavedTVs() {
        savedTVs = persistence.loadTVs()
    }
}
