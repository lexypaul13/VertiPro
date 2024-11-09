import SwiftUI
import Charts

struct AccuracyTrendChart: View {
    let dataPoints: [ExerciseDataPoint]
    
    var body: some View {
        Chart {
            ForEach(dataPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Accuracy", point.averageAccuracy)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.blue.gradient)
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
            
            ForEach(dataPoints) { point in
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Accuracy", point.averageAccuracy)
                )
                .foregroundStyle(Color.blue)
                .symbolSize(40)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date, format: .dateTime.month().day())
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 10)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Double.self) {
                        Text("\(Int(intValue))%")
                    }
                }
            }
        }
        .chartYScale(domain: 0...100)
        .frame(height: 300)
        .padding()
    }
} 
