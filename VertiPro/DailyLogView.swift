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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date Picker
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    // View Selector
                    Picker("View", selection: $selectedView) {
                        Text("Daily").tag("Daily")
                        Text("Weekly").tag("Weekly")
                        Text("Monthly").tag("Monthly")
                        Text("Yearly").tag("Yearly")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Statistics Summary
                    if !filteredData.isEmpty {
                        StatisticsSummaryView(sessions: filteredData)
                            .padding(.horizontal)
                    } else {
                        Text("No data available for selected period")
                            .foregroundColor(.gray)
                            .padding()
                    }

                    // Chart
                    if !filteredData.isEmpty {
                        DailyAccuracyChart(sessions: filteredData)
                    }
                }
            }
            .navigationTitle("Daily Log")
        }
    }
}

// Helper view for statistics
struct StatisticsSummaryView: View {
    let sessions: [ExerciseSession]

    var averageAccuracy: Double {
        let accuracies = sessions.map { $0.accuracy }
        return accuracies.isEmpty ? 0 : accuracies.reduce(0, +) / Double(accuracies.count)
    }

    var totalDuration: Int {
        sessions.map { $0.duration }.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Summary")
                .font(.headline)

            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Avg. Accuracy")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(Int(averageAccuracy))%")
                        .font(.title3)
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Total Duration")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(totalDuration) sec")
                        .font(.title3)
                        .bold()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    DailyLogView()
}
