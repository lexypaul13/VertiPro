//
//  DashBoardView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//


import SwiftUI
import Charts // Make sure to import the Charts framework

// Data model for the chart data points
struct ExerciseDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let averageAccuracy: Double
}

struct DashboardView: View {
    @ObservedObject var dataStore = ExerciseDataStore.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress Circles
                HStack(spacing: 20) {
                    ProgressCircleView(title: "Total Sessions", progress: totalSessionsProgress)
                    ProgressCircleView(title: "Average Accuracy", progress: averageAccuracyProgress)
                }
                .padding()
                
                // Chart Section
                if !dataStore.sessions.isEmpty {
                    // Chart Title
                    Text("Average Accuracy Over Time")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        ForEach(dataPoints()) { dataPoint in
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Average Accuracy", dataPoint.averageAccuracy)
                            )
                            .foregroundStyle(Color.blue)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                    }
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks(values: xAxisValues()) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(date, format: .dateTime.month(.abbreviated).day())
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let yValue = value.as(Double.self) {
                                    Text("\(Int(yValue))%")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding()
                } else {
                    Text("No exercise data available. Start your first exercise!")
                        .padding()
                }
                
                // Start Exercise Button
                NavigationLink(destination: ExerciseSetupView()) {
                    Text("Start Exercise")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .navigationBarTitle("Dashboard", displayMode: .inline)
        }
    }
    
    // Calculate progress values
    var totalSessionsProgress: Double {
        let totalSessions = Double(dataStore.sessions.count)
        let goal = 10.0 // For example, the goal is 10 sessions
        return min(totalSessions / goal, 1.0)
    }
    
    var averageAccuracyProgress: Double {
        let accuracies = dataStore.sessions.map { $0.accuracy }
        let averageAccuracy = accuracies.isEmpty ? 0 : accuracies.reduce(0, +) / Double(accuracies.count)
        return averageAccuracy / 100.0 // Since accuracy is out of 100%
    }
    
    // Prepare data points for the chart
    func dataPoints() -> [ExerciseDataPoint] {
        let calendar = Calendar.current
        var points: [ExerciseDataPoint] = []
        
        // Group sessions by day
        let groupedSessions = Dictionary(grouping: dataStore.sessions) { session in
            calendar.startOfDay(for: session.date)
        }
        
        // Create data points
        for (date, sessions) in groupedSessions {
            let totalAccuracy = sessions.reduce(0) { $0 + $1.accuracy }
            let averageAccuracy = totalAccuracy / Double(sessions.count)
            points.append(ExerciseDataPoint(date: date, averageAccuracy: averageAccuracy))
        }
        
        // Sort data points by date
        return points.sorted { $0.date < $1.date }
    }
    
    // Helper function to generate x-axis values
    func xAxisValues() -> [Date] {
        guard let minDate = dataStore.sessions.map({ $0.date }).min(),
              let maxDate = dataStore.sessions.map({ $0.date }).max(),
              minDate != maxDate else {
            // If only one date or min and max are the same, return the session dates
            return dataStore.sessions.map { $0.date }
        }
        
        var dates: [Date] = []
        let totalInterval = maxDate.timeIntervalSince(minDate)
        let interval = totalInterval / 6 // For 7 labels
        
        for i in 0...6 {
            let date = minDate.addingTimeInterval(interval * Double(i))
            dates.append(date)
        }
        return dates
    }
}


