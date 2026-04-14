import Foundation

final class TVPersistenceService {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let key = "saved_tvs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadTVs() -> [SonyTV] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? decoder.decode([SonyTV].self, from: data)) ?? []
    }

    func saveTVs(_ tvs: [SonyTV]) {
        guard let data = try? encoder.encode(tvs) else { return }
        defaults.set(data, forKey: key)
    }

    func addOrUpdate(_ tv: SonyTV) {
        var tvs = loadTVs()
        if let index = tvs.firstIndex(where: { $0.id == tv.id }) {
            tvs[index] = tv
        } else {
            tvs.append(tv)
        }
        saveTVs(tvs)
    }

    func remove(id: UUID) {
        var tvs = loadTVs()
        tvs.removeAll { $0.id == id }
        saveTVs(tvs)
    }
}
