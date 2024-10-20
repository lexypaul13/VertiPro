import SwiftUI
import Charts

struct DailyLogView: View {
    @ObservedObject var dataStore = ExerciseDataStore.shared
    @State private var selectedDate = Date()
    @State private var selectedView = "Daily"

    var filteredData: [ExerciseSession] {
        let calendar = Calendar.current
        return dataStore.sessions.filter {
            switch selectedView {
            case "Daily":
                return calendar.isDate($0.date, inSameDayAs: selectedDate)
            case "Weekly":
                return calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .weekOfYear)
            case "Monthly":
                return calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .month)
            case "Yearly":
                return calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .year)
            default:
                return false
            }
        }.sorted { $0.date < $1.date }
    }

    var averageAccuracy: Double {
        let accuracies = filteredData.map { $0.accuracy }
        return accuracies.isEmpty ? 0 : accuracies.reduce(0, +) / Double(accuracies.count)
    }

    var totalDuration: Int {
        return filteredData.map { $0.duration }.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Date Picker
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)

                    // View Selector
                    Picker("View", selection: $selectedView) {
                        Text("Daily").tag("Daily")
                        Text("Weekly").tag("Weekly")
                        Text("Monthly").tag("Monthly")
                        Text("Yearly").tag("Yearly")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Summary Statistics
                    if !filteredData.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Average Accuracy: \(String(format: "%.1f", averageAccuracy))%")
                            Text("Total Duration: \(totalDuration) seconds")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    }

                    // Charts
                    ScrollView {
                        if filteredData.isEmpty {
                            Text("No data available for the selected period.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Daily Accuracy")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                Chart {
                                    ForEach(filteredData) { session in
                                        LineMark(
                                            x: .value("Date", session.date),
                                            y: .value("Accuracy", session.accuracy)
                                        )
                                        .foregroundStyle(Color.blue)
                                        .lineStyle(StrokeStyle(lineWidth: 2))
                                    }
                                    ForEach(filteredData) { session in
                                        PointMark(
                                            x: .value("Date", session.date),
                                            y: .value("Accuracy", session.accuracy)
                                        )
                                        .foregroundStyle(Color.blue)
                                        .symbolSize(30)
                                    }
                                }
                                .chartYScale(domain: 0...100)
                                .chartXAxis {
                                    AxisMarks(values: xAxisValues()) { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                            .foregroundStyle(Color.gray.opacity(0.3))
                                        AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                                            .foregroundStyle(Color.gray.opacity(0.3))
                                        AxisValueLabel() {
                                            if let date = value.as(Date.self) {
                                                Text(date.formatted(dateFormat()))
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                            .foregroundStyle(Color.gray.opacity(0.3))
                                        AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                                            .foregroundStyle(Color.gray.opacity(0.3))
                                        AxisValueLabel() {
                                            if let yValue = value.as(Double.self) {
                                                Text("\(Int(yValue))%")
                                                    .font(.caption2)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 200)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Daily Log", displayMode: .inline)
        }
        .preferredColorScheme(.dark)
    }

    // Helper function to generate x-axis values
    func xAxisValues() -> [Date] {
        guard let minDate = filteredData.map({ $0.date }).min(),
              let maxDate = filteredData.map({ $0.date }).max(),
              minDate != maxDate else {
            // If only one date or min and max are the same, return the session dates
            return filteredData.map { $0.date }
        }

        var dates: [Date] = []
        let totalInterval = maxDate.timeIntervalSince(minDate)
        let interval = totalInterval / 4 // Divide into 4 intervals for 5 labels

        for i in 0...4 {
            let date = minDate.addingTimeInterval(interval * Double(i))
            dates.append(date)
        }
        return dates
    }

    // Helper function to format dates based on selected view
    func dateFormat() -> Date.FormatStyle {
        switch selectedView {
        case "Daily":
            return .dateTime.hour().minute()
        case "Weekly", "Monthly":
            return .dateTime.month(.abbreviated).day()
        case "Yearly":
            return .dateTime.year().month(.abbreviated)
        default:
            return .dateTime.month().day()
        }
    }
}



#Preview {
    DailyLogView()
}
