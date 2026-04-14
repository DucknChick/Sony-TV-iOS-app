import Foundation

struct SonyTV: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var ipAddress: String
    var macAddress: String?
    var authToken: String?
    var isPaired: Bool
    var lastSeen: Date

    var baseURL: URL {
        URL(string: "http://\(ipAddress)")!
    }

    init(
        id: UUID = UUID(),
        name: String,
        ipAddress: String,
        macAddress: String? = nil,
        authToken: String? = nil,
        isPaired: Bool = false,
        lastSeen: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.ipAddress = ipAddress
        self.macAddress = macAddress
        self.authToken = authToken
        self.isPaired = isPaired
        self.lastSeen = lastSeen
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SonyTV, rhs: SonyTV) -> Bool {
        lhs.id == rhs.id
    }
}
