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
            ScrollView {
                VStack(spacing: 20) {
                    // Four Charts in Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ], spacing: 20) {
                        // Total Sessions
                        ChartCard(
                            title: "Total\nSessions",
                            value: Double(dataStore.sessions.count),
                            total: Double(dataStore.sessions.count), // Update total to match value
                            color: .blue,
                            showValue: true
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
                            data: [
                                ChartData(
                                    label: "30s",
                                    value: Double(exerciseModeCounts.thirtySeconds),
                                    color: ChartData.colorScheme[0]
                                ),
                                ChartData(
                                    label: "60s",
                                    value: Double(exerciseModeCounts.sixtySeconds),
                                    color: ChartData.colorScheme[1]
                                )
                            ]
                        )
                        
                        // Head Movement Frequency
                        PieChartCard(
                            title: "Head Movement",
                            data: [
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
                // Force reload data when view appears
                dataStore.clearAndReloadData()
            }
        }
    }
    
    // Computed Properties
    private var averageAccuracy: Double {
        let accuracies = dataStore.sessions.map { $0.accuracy }
        return accuracies.isEmpty ? 0 : accuracies.reduce(0, +) / Double(accuracies.count)
    }
    
    private var exerciseModeCounts: (thirtySeconds: Int, sixtySeconds: Int) {
        let thirtySeconds = dataStore.sessions.filter { $0.duration == 30 }.count
        let sixtySeconds = dataStore.sessions.filter { $0.duration == 60 }.count
        print("Exercise Mode - Raw counts: 30s: \(thirtySeconds), 60s: \(sixtySeconds)")
        return (thirtySeconds, sixtySeconds)
    }
    
    private var headMovementCounts: (all: Int, upDown: Int, leftRight: Int) {
        let all = dataStore.sessions.filter { session in
            let hasUpDown = session.movements.contains { $0.direction == .up || $0.direction == .down }
            let hasLeftRight = session.movements.contains { $0.direction == .left || $0.direction == .right }
            return hasUpDown && hasLeftRight
        }.count
        
        let upDown = dataStore.sessions.filter { session in
            let movements = session.movements
            return movements.allSatisfy { $0.direction == .up || $0.direction == .down }
        }.count
        
        let leftRight = dataStore.sessions.filter { session in
            let movements = session.movements
            return movements.allSatisfy { $0.direction == .left || $0.direction == .right }
        }.count
        
        print("Head Movement - Raw counts: all=\(all), upDown=\(upDown), leftRight=\(leftRight)")
        return (all, upDown, leftRight)
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
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Chart {
                SectorMark(
                    angle: .value("Value", value),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(color.gradient)
                
                SectorMark(
                    angle: .value("Remaining", max(0, total - value)),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(color.opacity(0.2))
            }
            .frame(height: 120)
            
            if showPercentage {
                Text("\(Int(value))%")
                    .font(.title2)
                    .bold()
            } else if showValue {
                Text("\(Int(value))")
                    .font(.title2)
                    .bold()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
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
                .foregroundStyle(by: .value("Category", item.label))
            }
            .frame(height: 200)
            .chartLegend(position: .bottom) {
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
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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
        path.addArc(center: center,
                   radius: radius,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: false)
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


