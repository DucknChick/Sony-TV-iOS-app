import Foundation

struct BackupV1: Codable {
    let version: Int
    let exportedAt: Date
    let categories: [CategoryDTO]
    let assets: [AssetDTO]

    struct CategoryDTO: Codable {
        let name: String
        let isLiability: Bool
        let sortOrder: Int
        let isBuiltIn: Bool
        let tracksCostBasis: Bool
        let colorHex: String?
    }

    struct AssetDTO: Codable {
        let id: UUID
        let name: String
        let categoryName: String?
        let institution: String?
        let notes: String?
        let purchaseDate: Date?
        let costBasis: String?
        let owner: String
        let createdAt: Date
        let archivedAt: Date?
        let valuations: [ValuationDTO]
    }

    struct ValuationDTO: Codable {
        let id: UUID
        let monthKey: Int
        let amount: String
        let recordedAt: Date
    }
}
