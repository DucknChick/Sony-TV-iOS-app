import Foundation

enum TVServiceEndpoint: String {
    case system        = "system"
    case audio         = "audio"
    case avContent     = "avContent"
    case accessControl = "accessControl"
    case appControl    = "appControl"
    case guide         = "guide"
    case videoScreen   = "videoScreen"

    var path: String { "/sony/\(rawValue)" }
}

struct TVInput: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let uri: String
    let icon: String?

    init(id: String, title: String, uri: String, icon: String? = nil) {
        self.id = id
        self.title = title
        self.uri = uri
        self.icon = icon
    }
}

struct SystemInfo: Codable {
    let product: String?
    let model: String?
    let generation: String?
    let name: String?
    let macAddr: String?
}

struct VolumeInfo: Codable {
    let target: String
    let volume: Int
    let mute: Bool
    let maxVolume: Int
    let minVolume: Int
}
