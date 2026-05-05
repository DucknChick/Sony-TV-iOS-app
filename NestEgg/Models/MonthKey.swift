import Foundation

struct MonthKey: Hashable, Comparable, Codable, CustomStringConvertible {
    let year: Int
    let month: Int

    init(year: Int, month: Int) {
        precondition((1...12).contains(month), "month must be 1-12")
        self.year = year
        self.month = month
    }

    var rawValue: Int { year * 12 + (month - 1) }

    init(rawValue: Int) {
        self.year = rawValue / 12
        self.month = (rawValue % 12) + 1
    }

    static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return c
    }()

    static func current(in calendar: Calendar = .current, now: Date = .now) -> MonthKey {
        let comps = calendar.dateComponents([.year, .month], from: now)
        return MonthKey(year: comps.year ?? 1970, month: comps.month ?? 1)
    }

    static func from(date: Date, calendar: Calendar = .current) -> MonthKey {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return MonthKey(year: comps.year ?? 1970, month: comps.month ?? 1)
    }

    var firstOfMonth: Date {
        var c = DateComponents()
        c.year = year
        c.month = month
        c.day = 1
        return MonthKey.calendar.date(from: c) ?? .distantPast
    }

    func adding(months: Int) -> MonthKey {
        MonthKey(rawValue: rawValue + months)
    }

    static func < (lhs: MonthKey, rhs: MonthKey) -> Bool { lhs.rawValue < rhs.rawValue }

    var description: String { String(format: "%04d-%02d", year, month) }

    var shortLabel: String {
        let f = DateFormatter()
        f.calendar = MonthKey.calendar
        f.timeZone = MonthKey.calendar.timeZone
        f.dateFormat = "MMM yyyy"
        return f.string(from: firstOfMonth)
    }
}
