import SwiftUI
import Charts

struct NetWorthSparkline: View {
    let series: [MonthSeries.Point]

    var body: some View {
        Chart {
            ForEach(series, id: \.month) { point in
                LineMark(
                    x: .value("Month", point.month.firstOfMonth),
                    y: .value("Net Worth", point.amount.doubleValue)
                )
                .interpolationMethod(.monotone)
                AreaMark(
                    x: .value("Month", point.month.firstOfMonth),
                    y: .value("Net Worth", point.amount.doubleValue)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.35), Color.accentColor.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 80)
    }
}
