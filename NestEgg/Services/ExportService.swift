import Foundation
import SwiftData
import UniformTypeIdentifiers
import SwiftUI

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

struct BackupDocument: FileDocument {
    static let readableContentTypes: [UTType] = [.json]
    static let writableContentTypes: [UTType] = [.json]

    let data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

enum ExportService {
    @MainActor
    static func makeBackupData(in context: ModelContext) throws -> Data {
        let categories = (try? context.fetch(FetchDescriptor<Category>())) ?? []
        let assets = (try? context.fetch(FetchDescriptor<Asset>())) ?? []

        let categoryDTOs = categories.map {
            BackupV1.CategoryDTO(
                name: $0.name,
                isLiability: $0.isLiability,
                sortOrder: $0.sortOrder,
                isBuiltIn: $0.isBuiltIn,
                tracksCostBasis: $0.tracksCostBasis,
                colorHex: $0.colorHex
            )
        }

        let assetDTOs = assets.map { asset -> BackupV1.AssetDTO in
            let valuations = asset.sortedValuations.map {
                BackupV1.ValuationDTO(
                    id: $0.id,
                    monthKey: $0.monthKey,
                    amount: stringify($0.amount),
                    recordedAt: $0.recordedAt
                )
            }
            return BackupV1.AssetDTO(
                id: asset.id,
                name: asset.name,
                categoryName: asset.category?.name,
                institution: asset.institution,
                notes: asset.notes,
                purchaseDate: asset.purchaseDate,
                costBasis: asset.costBasis.map(stringify),
                owner: asset.owner.rawValue,
                createdAt: asset.createdAt,
                archivedAt: asset.archivedAt,
                valuations: valuations
            )
        }

        let payload = BackupV1(
            version: 1,
            exportedAt: .now,
            categories: categoryDTOs,
            assets: assetDTOs
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(payload)
    }

    private static func stringify(_ d: Decimal) -> String {
        var copy = d
        return NSDecimalString(&copy, Locale(identifier: "en_US_POSIX"))
    }
}
