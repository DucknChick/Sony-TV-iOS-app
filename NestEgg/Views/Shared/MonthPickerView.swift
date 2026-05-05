import SwiftUI

struct MonthPickerView: View {
    @Binding var selection: MonthKey
    var earliestYear: Int = Calendar.current.component(.year, from: .now) - 50

    private let months = Array(1...12)

    var body: some View {
        HStack {
            Picker("Month", selection: monthBinding) {
                ForEach(months, id: \.self) { m in
                    Text(monthName(m)).tag(m)
                }
            }
            Picker("Year", selection: yearBinding) {
                ForEach(years, id: \.self) { y in
                    Text(verbatim: String(y)).tag(y)
                }
            }
        }
        .pickerStyle(.menu)
    }

    private var years: [Int] {
        let thisYear = Calendar.current.component(.year, from: .now)
        return Array(earliestYear...(thisYear + 1)).reversed()
    }

    private var monthBinding: Binding<Int> {
        Binding(
            get: { selection.month },
            set: { selection = MonthKey(year: selection.year, month: $0) }
        )
    }

    private var yearBinding: Binding<Int> {
        Binding(
            get: { selection.year },
            set: { selection = MonthKey(year: $0, month: selection.month) }
        )
    }

    private func monthName(_ m: Int) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        var c = DateComponents()
        c.month = m
        c.day = 1
        c.year = 2000
        let cal = Calendar(identifier: .gregorian)
        return f.string(from: cal.date(from: c) ?? .now)
    }
}
