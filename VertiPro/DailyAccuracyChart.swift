import SwiftUI
import Charts

struct DailyAccuracyChart: View {
    let sessions: [ExerciseSession]
    
    // Add computed property for date range
    private var dateRange: ClosedRange<Date> {
        let sortedDates = sessions.map(\.date).sorted()
        if let firstDate = sortedDates.first,
           let lastDate = sortedDates.last {
            return firstDate...lastDate
        }
        // Fallback to today if no dates available
        return Date()...Date()
    }
    
    var body: some View {
        VStack {
            chartView
                .frame(height: 300)
                .padding()
            
            legendView
                .padding(.bottom)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    // MARK: - Chart View
    private var chartView: some View {
        Chart {
            ForEach(sessions) { session in
                LineMark(
                    x: .value("Date", session.date),
                    y: .value("Accuracy", session.accuracy)
                )
                .foregroundStyle(Color.blue.gradient)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .symbol(.circle)
                .symbolSize(10)
            }
        }
        .chartXScale(domain: dateRange)
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.black.opacity(0.1))
                .border(Color.gray.opacity(0.2), width: 1)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.gray.opacity(0.3))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.gray.opacity(0.3))
                AxisValueLabel(format: .dateTime.day().month())
            }
        }
        .chartYAxis {
            AxisMarks(values: .stride(by: 20)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.gray.opacity(0.3))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.gray.opacity(0.3))
                AxisValueLabel("\(Int(value.as(Double.self) ?? 0))%")
            }
        }
        .chartYScale(domain: 0...100)
        .padding(.vertical)
    }
    
    // MARK: - Legend View
    private var legendView: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
            Text("Session Accuracy")
                .font(.caption)
        }
    }
}

// MARK: - Preview
#Preview {
    DailyAccuracyChart(sessions: [
        ExerciseSession(
            date: Date(),
            duration: 180,
            score: 15,
            totalTargets: 20,
            movements: [],
            dizzinessLevel: 5
        ),
        ExerciseSession(
            date: Date().addingTimeInterval(3600),
            duration: 200,
            score: 18,
            totalTargets: 20,
            movements: [],
            dizzinessLevel: 4
        )
    ])
}
