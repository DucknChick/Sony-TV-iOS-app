import Foundation

enum ImportError: LocalizedError {
    case invalidJSON(String)
    case unsupportedVersion(Int)

    var errorDescription: String? {
        switch self {
        case .invalidJSON(let detail):
            return "Couldn't read backup file: \(detail)"
        case .unsupportedVersion(let v):
            return "Backup version \(v) isn't supported by this build."
        }
    }
}

enum ImportService {
    static func decode(_ data: Data) throws -> BackupV1 {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let backup = try decoder.decode(BackupV1.self, from: data)
            guard backup.version == 1 else {
                throw ImportError.unsupportedVersion(backup.version)
            }
            return backup
        } catch let err as ImportError {
            throw err
        } catch {
            throw ImportError.invalidJSON(error.localizedDescription)
        }
    }

    struct Counts {
        let categories: Int
        let assets: Int
        let valuations: Int
    }

    static func counts(of backup: BackupV1) -> Counts {
        Counts(
            categories: backup.categories.count,
            assets: backup.assets.count,
            valuations: backup.assets.reduce(0) { $0 + $1.valuations.count }
        )
    }
}
