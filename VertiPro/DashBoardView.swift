//
//  DashboardView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import SwiftUI
import Charts // Make sure to import the Charts framework
struct DashboardView: View {
    @ObservedObject var dataStore = ExerciseDataStore.shared

    // Pre-computed data for charts
    private var exerciseModeData: [ChartData] {
        [
            ChartData(
                label: "30s",
                value: Double(exerciseModeCounts.thirtySeconds),
                color: ChartData.colorScheme[0]
            ),
            ChartData(
                label: "60s",
                value: Double(exerciseModeCounts.sixtySeconds),
                color: ChartData.colorScheme[1]
            ),
            ChartData(
                label: "2min",
                value: Double(exerciseModeCounts.twoMinutes),
                color: ChartData.colorScheme[2]
            )
        ]
    }

    private var headMovementData: [ChartData] {
        [
            ChartData(
                label: "All",
                value: Double(headMovementCounts.all),
                color: ChartData.colorScheme[0]
            ),
            ChartData(
                label: "Up/Down",
                value: Double(headMovementCounts.upDown),
                color: ChartData.colorScheme[1]
            ),
            ChartData(
                label: "Left/Right",
                value: Double(headMovementCounts.leftRight),
                color: ChartData.colorScheme[2]
            )
        ]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Four Charts in Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ], spacing: 20) {
                        // Total Sessions - using inline card
                        TotalSessionsCard(
                            totalSessions: dataStore.sessions.count,
                            weeklyChange: dataStore.weeklyChange
                        )

                        // Average Accuracy
                        ChartCard(
                            title: "Average\nAccuracy",
                            value: averageAccuracy,
                            total: 100,
                            color: .green,
                            showPercentage: true
                        )

                        // Exercise Mode Frequency
                        PieChartCard(
                            title: "Exercise Mode",
                            data: exerciseModeData
                        )

                        // Head Movement Frequency
                        PieChartCard(
                            title: "Head Movement",
                            data: headMovementData
                        )
                    }
                    .padding()

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
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                dataStore.clearAndReloadData()
            }
        }
    }

    // Computed Properties
    private var averageAccuracy: Double {
        let accuracies = dataStore.sessions.map { $0.accuracy }
        return accuracies.isEmpty ? 0 : accuracies.reduce(0, +) / Double(accuracies.count)
    }

    private var exerciseModeCounts: (thirtySeconds: Int, sixtySeconds: Int, twoMinutes: Int) {
        let sessions = dataStore.sessions
        let thirtySeconds = sessions.filter { $0.duration == 30 }.count
        let sixtySeconds = sessions.filter { $0.duration == 60 }.count
        let twoMinutes = sessions.filter { $0.duration == 120 }.count
        return (thirtySeconds, sixtySeconds, twoMinutes)
    }

    private var headMovementCounts: (all: Int, upDown: Int, leftRight: Int) {
        let sessions = dataStore.sessions

        let all = sessions.filter { session in
            let hasUpDown = session.movements.contains { $0.direction == .up || $0.direction == .down }
            let hasLeftRight = session.movements.contains { $0.direction == .left || $0.direction == .right }
            return hasUpDown && hasLeftRight
        }.count

        let upDown = sessions.filter { session in
            session.movements.allSatisfy { $0.direction == .up || $0.direction == .down }
        }.count

        let leftRight = sessions.filter { session in
            session.movements.allSatisfy { $0.direction == .left || $0.direction == .right }
        }.count

        print("Head Movement - Raw counts: all=\(all), upDown=\(upDown), leftRight=\(leftRight)")
        return (all, upDown, leftRight)
    }
}

// Total Sessions Card
struct TotalSessionsCard: View {
    let totalSessions: Int
    let weeklyChange: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Sessions")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("\(totalSessions)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            if weeklyChange != 0 {
                HStack(spacing: 4) {
                    Image(systemName: weeklyChange > 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(abs(weeklyChange)) this week")
                        .font(.caption)
                }
                .foregroundColor(weeklyChange > 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 8,
            x: 0,
            y: 2
        )
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color

    static let colorScheme: [Color] = [
        .blue,      // Annual/All
        .green,     // Monthly/Up&Down
        .orange     // Lifetime/Left&Right
    ]
}

struct ChartCard: View {
    let title: String
    let value: Double
    let total: Double
    let color: Color
    var showPercentage: Bool = false
    var showValue: Bool = false

    private var displayValue: String {
        if value.isNaN || value.isInfinite {
            return "0"
        }

        if showPercentage {
            return "\(Int(max(0, min(100, value))))%"
        } else if showValue {
            return "\(Int(max(0, value)))"
        }
        return ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.leading)

            if showPercentage {
                PercentageChartView(
                    value: value,
                    total: total,
                    color: color,
                    displayValue: displayValue
                )
            } else {
                TotalSessionsChartView(
                    value: value,
                    color: color,
                    displayValue: displayValue
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct PercentageChartView: View {
    let value: Double
    let total: Double
    let color: Color
    let displayValue: String

    var body: some View {
        VStack {
            Chart {
                SectorMark(
                    angle: .value("Value", value.isNaN || value.isInfinite ? 0 : value),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(color.gradient)

                SectorMark(
                    angle: .value("Remaining", max(0, total - (value.isNaN || value.isInfinite ? 0 : value))),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(color.opacity(0.2))
            }
            .frame(height: 120)

            Text(displayValue)
                .font(.title2)
                .bold()
        }
    }
}

struct TotalSessionsChartView: View {
    let value: Double
    let color: Color
    let displayValue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(displayValue)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(color)

            // Weekly trend bars
            let weeklyData = (1...7).map { day in
                WeeklySessionData(
                    day: "D\(day)",
                    sessions: Double.random(in: 1...5) // Replace with actual weekly data
                )
            }

            Chart(weeklyData) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Sessions", item.sessions)
                )
                .foregroundStyle(color)
            }
            .frame(height: 60)

            Text("Last 7 days")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct WeeklySessionData: Identifiable {
    let id = UUID()
    let day: String
    let sessions: Double
}

struct PieChartCard: View {
    let title: String
    let data: [ChartData]

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Chart(data) { item in
                SectorMark(
                    angle: .value(item.label, item.value)
                )
                .foregroundStyle(item.color)
            }
            .frame(height: 200)

            LegendView(data: data)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct LegendView: View {
    let data: [ChartData]

    var body: some View {
        HStack(spacing: 16) {
            ForEach(data) { item in
                HStack(spacing: 4) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 8, height: 8)
                    Text(item.label)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// Add PieSlice shape
struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

// Add this at the bottom of the file
#Preview {
    let store = ExerciseDataStore.shared

    // Add some test data if empty
    if store.sessions.isEmpty {
        // Add 30-second sessions
        store.addSession(ExerciseSession(
            date: Date().addingTimeInterval(-86400), // Yesterday
            duration: 30,
            score: 8,
            totalTargets: 10,
            movements: [
                Movement(direction: .up, responseTime: 1.0, timestamp: Date()),
                Movement(direction: .down, responseTime: 1.2, timestamp: Date())
            ],
            dizzinessLevel: 5
        ))

        // Add 60-second sessions
        store.addSession(ExerciseSession(
            date: Date(),
            duration: 60,
            score: 15,
            totalTargets: 20,
            movements: [
                Movement(direction: .left, responseTime: 0.8, timestamp: Date()),
                Movement(direction: .right, responseTime: 1.0, timestamp: Date()),
                Movement(direction: .up, responseTime: 0.9, timestamp: Date())
            ],
            dizzinessLevel: 3
        ))

        // Add mixed movement session
        store.addSession(ExerciseSession(
            date: Date().addingTimeInterval(-43200), // 12 hours ago
            duration: 45,
            score: 12,
            totalTargets: 15,
            movements: [
                Movement(direction: .up, responseTime: 1.1, timestamp: Date()),
                Movement(direction: .left, responseTime: 0.9, timestamp: Date())
            ],
            dizzinessLevel: 4
        ))
    }

    return DashboardView()
}
