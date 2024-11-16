import SwiftUI
import Charts

struct MovementTrendChart: View {
    let sessions: [ExerciseSession]
    
    private var dateRange: ClosedRange<Date> {
        let sortedDates = sessions.map(\.date).sorted()
        if let firstDate = sortedDates.first,
           let lastDate = sortedDates.last {
            return firstDate...lastDate
        }
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
    
    private var chartView: some View {
        Chart {
            ForEach(sessions) { session in
                LineMark(
                    x: .value("Date", session.date),
                    y: .value("Movements", session.movements.count)
                )
                .foregroundStyle(Color.blue.gradient)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .symbol(.circle)
                .symbolSize(8)
            }
        }
    }
    
    private var legendView: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
            Text("Movements per Session")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
} 