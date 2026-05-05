import Foundation
import SwiftData

@Model
final class Valuation {
    var id: UUID
    var monthKey: Int
    var amount: Decimal
    var recordedAt: Date

    var asset: Asset?

    init(monthKey: Int, amount: Decimal, asset: Asset? = nil) {
        self.id = UUID()
        self.monthKey = monthKey
        self.amount = amount
        self.recordedAt = .now
        self.asset = asset
    }

    convenience init(month: MonthKey, amount: Decimal, asset: Asset? = nil) {
        self.init(monthKey: month.rawValue, amount: amount, asset: asset)
    }

    var month: MonthKey {
        get { MonthKey(rawValue: monthKey) }
        set { monthKey = newValue.rawValue }
    }
}
