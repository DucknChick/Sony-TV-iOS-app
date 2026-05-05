import Foundation

enum SeedData {
    struct CategorySeed {
        let name: String
        let isLiability: Bool
        let sortOrder: Int
        let tracksCostBasis: Bool
    }

    static let builtInCategories: [CategorySeed] = [
        // Assets
        .init(name: "Cash & Checking", isLiability: false, sortOrder: 10, tracksCostBasis: false),
        .init(name: "Brokerage",       isLiability: false, sortOrder: 20, tracksCostBasis: true),
        .init(name: "Retirement",      isLiability: false, sortOrder: 30, tracksCostBasis: true),
        .init(name: "Real Estate",     isLiability: false, sortOrder: 40, tracksCostBasis: true),
        .init(name: "Crypto",          isLiability: false, sortOrder: 50, tracksCostBasis: true),
        // Liabilities
        .init(name: "Mortgage",        isLiability: true,  sortOrder: 110, tracksCostBasis: false),
        .init(name: "Credit Card",     isLiability: true,  sortOrder: 120, tracksCostBasis: false),
        .init(name: "Loan",            isLiability: true,  sortOrder: 130, tracksCostBasis: false),
        .init(name: "Other Liability", isLiability: true,  sortOrder: 140, tracksCostBasis: false),
    ]
}
