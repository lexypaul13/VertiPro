import SwiftUI
import Charts

struct DailyLogView: View {
    @ObservedObject var dataStore = ExerciseDataStore.shared
    @State private var selectedDate = Date()
    @State private var selectedView = "Daily"
    @State private var forceUpdate = UUID()
    
    // Add this struct to create unique IDs for data points

    // Add this computed property for chart data
    private var chartData: [ChartDataPoint] {
        let sessions = filteredData
        
        let rawData: [(date: Date, value: Double)]
        
        switch selectedView {
        case "Daily":
            rawData = smoothDailyData(sessions)
        case "Weekly":
            rawData = aggregateWeeklyData(sessions)
        case "Monthly":
            rawData = aggregateMonthlyData(sessions)
        case "Yearly":
            rawData = aggregateYearlyData(sessions)
        default:
            rawData = []
        }
        
        return rawData.map { ChartDataPoint(date: $0.date, value: $0.value) }
    }
    
    var filteredData: [ExerciseSession] {
        let calendar = Calendar.current
        let startOfSelectedDate = calendar.startOfDay(for: selectedDate)
        
        return dataStore.sessions.filter { session in
            switch selectedView {
            case "Daily":
                return calendar.isDate(session.date, inSameDayAs: selectedDate)
            case "Weekly":
                let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
                let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
                return session.date >= weekStart && session.date < weekEnd
            case "Monthly":
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
                let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
                return session.date >= monthStart && session.date < monthEnd
            case "Yearly":
                let yearStart = calendar.date(from: calendar.dateComponents([.year], from: selectedDate))!
                let yearEnd = calendar.date(byAdding: .year, value: 1, to: yearStart)!
                return session.date >= yearStart && session.date < yearEnd
            default:
                return false
            }
        }.sorted { $0.date < $1.date }
    }
    
    private func smoothDailyData(_ sessions: [ExerciseSession]) -> [(date: Date, value: Double)] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Filter sessions for selected day
        let todaySessions = sessions.filter { session in
            session.date >= startOfDay && session.date < endOfDay
        }
        
        var dataPoints: [(date: Date, value: Double)] = []
        
        // Create hourly data points
        for hour in 0..<24 {
            if let hourDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate) {
                let hourEnd = calendar.date(byAdding: .hour, value: 1, to: hourDate)!
                
                // Get sessions for this hour
                let hourSessions = todaySessions.filter { session in
                    session.date >= hourDate && session.date < hourEnd
                }
                
                if !hourSessions.isEmpty {
                    let avgAccuracy = hourSessions.map(\.accuracy).reduce(0, +) / Double(hourSessions.count)
                    dataPoints.append((date: hourDate, value: avgAccuracy))
                }
            }
        }
        
        return dataPoints.sorted { $0.date < $1.date }
    }
    
    private func aggregateWeeklyData(_ sessions: [ExerciseSession]) -> [(date: Date, value: Double)] {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        // Filter sessions for selected week
        let weekSessions = sessions.filter { session in
            session.date >= weekStart && session.date < weekEnd
        }
        
        var dataPoints: [(date: Date, value: Double)] = []
        
        // Create daily data points for the week
        for dayOffset in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                let nextDay = calendar.date(byAdding: .day, value: 1, to: dayDate)!
                
                // Get sessions for this day
                let daySessions = weekSessions.filter { session in
                    session.date >= dayDate && session.date < nextDay
                }
                
                if !daySessions.isEmpty {
                    let avgAccuracy = daySessions.map(\.accuracy).reduce(0, +) / Double(daySessions.count)
                    dataPoints.append((date: dayDate, value: avgAccuracy))
                }
            }
        }
        
        return dataPoints.sorted { $0.date < $1.date }
    }
    
    private func aggregateMonthlyData(_ sessions: [ExerciseSession]) -> [(date: Date, value: Double)] {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        
        // Filter sessions for selected month
        let monthSessions = sessions.filter { session in
            session.date >= monthStart && session.date < monthEnd
        }
        
        var dataPoints: [(date: Date, value: Double)] = []
        
        // Get the range of days in the month
        if let range = calendar.range(of: .day, in: .month, for: selectedDate) {
            for day in range {
                if let dayDate = calendar.date(bySetting: .day, value: day, of: monthStart) {
                    let nextDay = calendar.date(byAdding: .day, value: 1, to: dayDate)!
                    
                    // Get sessions for this day
                    let daySessions = monthSessions.filter { session in
                        session.date >= dayDate && session.date < nextDay
                    }
                    
                    if !daySessions.isEmpty {
                        let avgAccuracy = daySessions.map(\.accuracy).reduce(0, +) / Double(daySessions.count)
                        dataPoints.append((date: dayDate, value: avgAccuracy))
                    }
                }
            }
        }
        
        return dataPoints.sorted { $0.date < $1.date }
    }
    
    private func aggregateYearlyData(_ sessions: [ExerciseSession]) -> [(date: Date, value: Double)] {
        let calendar = Calendar.current
        let yearStart = calendar.date(from: calendar.dateComponents([.year], from: selectedDate))!
        let yearEnd = calendar.date(byAdding: .year, value: 1, to: yearStart)!
        
        // Filter sessions for selected year
        let yearSessions = sessions.filter { session in
            session.date >= yearStart && session.date < yearEnd
        }
        
        var dataPoints: [(date: Date, value: Double)] = []
        
        // Create monthly data points
        for month in 1...12 {
            if let monthDate = calendar.date(bySetting: .month, value: month, of: yearStart) {
                let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthDate)!
                
                // Get sessions for this month
                let monthSessions = yearSessions.filter { session in
                    session.date >= monthDate && session.date < nextMonth
                }
                
                if !monthSessions.isEmpty {
                    let avgAccuracy = monthSessions.map(\.accuracy).reduce(0, +) / Double(monthSessions.count)
                    dataPoints.append((date: monthDate, value: avgAccuracy))
                }
            }
        }
        
        return dataPoints.sorted { $0.date < $1.date }
    }
    
    // Add this function to print debug information
    private func debugPrintFilteredData() {
        print("Selected Date: \(selectedDate)")
        print("Selected View: \(selectedView)")
        print("Total Sessions: \(dataStore.sessions.count)")
        print("Filtered Sessions: \(filteredData.count)")
        
        if !filteredData.isEmpty {
            print("First Session Date: \(filteredData.first!.date)")
            print("Last Session Date: \(filteredData.last!.date)")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    DatePickerSection(selectedDate: $selectedDate)
                        .onChange(of: selectedDate) { _ in
                            debugPrintFilteredData()
                            forceUpdate = UUID()
                        }
                    
                    ViewSelectorSection(selectedView: $selectedView)
                        .onChange(of: selectedView) { _ in
                            debugPrintFilteredData()
                            forceUpdate = UUID()
                        }
                    
                    if !filteredData.isEmpty {
                        StatisticsSummaryView(sessions: filteredData)
                            .padding(.horizontal)
                            .id(forceUpdate)
                        
                        ChartSection(
                            chartData: chartData,
                            selectedView: selectedView
                        )
                        .id(forceUpdate)
                    } else {
                        NoDataView()
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Daily Log")
            .background(Color.backgroundWhite)
            .onAppear {
                debugPrintFilteredData()
            }
        }
    }
}

// Break down into smaller components
struct DatePickerSection: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

struct ViewSelectorSection: View {
    @Binding var selectedView: String
    
    var body: some View {
        Picker("View", selection: $selectedView) {
            Text("Daily").tag("Daily")
            Text("Weekly").tag("Weekly")
            Text("Monthly").tag("Monthly")
            Text("Yearly").tag("Yearly")
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

struct NoDataView: View {
    var body: some View {
        Text("No data available for selected period")
            .foregroundColor(.gray)
            .padding()
    }
}

struct ChartSection: View {
    let chartData: [ChartDataPoint]
    let selectedView: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Accuracy Trend")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(chartData) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Accuracy", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Accuracy", point.value)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartXAxis {
                switch selectedView {
                case "Daily":
                    AxisMarks(values: .stride(by: 3600)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatDate(date, for: selectedView))
                                    .font(.caption)
                            }
                        }
                    }
                case "Weekly":
                    AxisMarks(values: .stride(by: 86400)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatDate(date, for: selectedView))
                                    .font(.caption)
                            }
                        }
                    }
                case "Monthly":
                    AxisMarks(values: .stride(by: Double(86400 * 7))) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatDate(date, for: selectedView))
                                    .font(.caption)
                            }
                        }
                    }
                case "Yearly":
                    AxisMarks(values: .stride(by: Double(86400 * 30))) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatDate(date, for: selectedView))
                                    .font(.caption)
                            }
                        }
                    }
                default:
                    AxisMarks()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date, for view: String) -> String {
        let formatter = DateFormatter()
        switch view {
        case "Daily": formatter.dateFormat = "HH:mm"
        case "Weekly": formatter.dateFormat = "EEE"
        case "Monthly": formatter.dateFormat = "MMM d"
        case "Yearly": formatter.dateFormat = "MMM"
        default: formatter.dateFormat = "MMM d"
        }
        return formatter.string(from: date)
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
                
                VStack(alignment: .trailing) {
                    Text("Total Duration")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(formatDuration(totalDuration))")
                        .font(.title3)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    private func formatDuration(_ seconds: Int) -> String {
        if seconds >= 3600 {
            return "\(seconds / 3600)h \((seconds % 3600) / 60)m"
        } else if seconds >= 60 {
            return "\(seconds / 60)m \(seconds % 60)s"
        } else {
            return "\(seconds)s"
        }
    }
}
 struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

#Preview {
    DailyLogView()
}
