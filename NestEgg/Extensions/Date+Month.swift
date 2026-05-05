import Foundation

extension Date {
    var firstOfMonth: Date {
        let cal = MonthKey.calendar
        let comps = cal.dateComponents([.year, .month], from: self)
        return cal.date(from: comps) ?? self
    }
}

extension Calendar {
    func monthsBetween(_ a: Date, _ b: Date) -> Int {
        let comps = dateComponents([.month], from: a.firstOfMonth, to: b.firstOfMonth)
        return comps.month ?? 0
    }
}
