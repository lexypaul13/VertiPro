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
                    // Four Circular Charts in Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 20),
                        GridItem(.flexible(), spacing: 20)
                    ], spacing: 20) {
                        // Total Sessions Circle
                        CircularProgressView(
                            title: "Total\nSessions",
                            value: Double(dataStore.sessions.count),
                            total: 100,
                            color: .blue,
                            showPercentage: false
                        )
                        
                        // Average Accuracy Circle
                        CircularProgressView(
                            title: "Average\nAccuracy",
                            value: averageAccuracy,
                            total: 100,
                            color: .green,
                            showPercentage: true
                        )
                        
                        // Exercise Mode Frequency
                        CircularChartView(
                            title: "Exercise Mode",
                            segments: [
                                .init(value: Double(exerciseModeCounts.thirtySeconds), color: .cyan, label: "30s"),
                                .init(value: Double(exerciseModeCounts.sixtySeconds), color: .blue, label: "60s")
                            ]
                        )
                        
                        // Head Movement Frequency
                        CircularChartView(
                            title: "Head Movement",
                            segments: [
                                .init(value: Double(headMovementCounts.all), color: .blue, label: "All"),
                                .init(value: Double(headMovementCounts.upDown), color: .yellow, label: "Up/Down"),
                                .init(value: Double(headMovementCounts.leftRight), color: .cyan, label: "Left/Right")
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
        }
    }
    
    // Computed Properties
    private var averageAccuracy: Double {
        let accuracies = dataStore.sessions.map { $0.accuracy }
        return accuracies.isEmpty ? 0 : accuracies.reduce(0, +) / Double(accuracies.count)
    }
    
    private var exerciseModeCounts: (thirtySeconds: Int, sixtySeconds: Int) {
        let thirtySeconds = dataStore.sessions.filter { $0.duration <= 30 }.count
        let sixtySeconds = dataStore.sessions.filter { $0.duration > 30 }.count
        return (thirtySeconds, sixtySeconds)
    }
    
    private var headMovementCounts: (all: Int, upDown: Int, leftRight: Int) {
        let all = dataStore.sessions.filter { session in
            session.movements.contains { $0.direction == .up || $0.direction == .down } &&
            session.movements.contains { $0.direction == .left || $0.direction == .right }
        }.count
        
        let upDown = dataStore.sessions.filter { session in
            session.movements.contains { $0.direction == .up || $0.direction == .down } &&
            !session.movements.contains { $0.direction == .left || $0.direction == .right }
        }.count
        
        let leftRight = dataStore.sessions.filter { session in
            !session.movements.contains { $0.direction == .up || $0.direction == .down } &&
            session.movements.contains { $0.direction == .left || $0.direction == .right }
        }.count
        
        return (all, upDown, leftRight)
    }
}

// Circular Progress View for single value circles
struct CircularProgressView: View {
    let title: String
    let value: Double
    let total: Double
    let color: Color
    let showPercentage: Bool
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(value/total))
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text(showPercentage ? "\(Int(value))%" : "\(Int(value))")
                    .font(.title2)
                    .bold()
            }
            .frame(width: 120, height: 120)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// Circular Chart View for multiple segments
struct CircularChartView: View {
    let title: String
    let segments: [Segment]
    
    struct Segment {
        let value: Double
        let color: Color
        let label: String
    }
    
    private var total: Double {
        segments.map(\.value).reduce(0, +)
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                
                ForEach(0..<segments.count, id: \.self) { index in
                    Circle()
                        .trim(
                            from: index == 0 ? 0 : segments[..<index].map(\.value).reduce(0, +) / total,
                            to: segments[...index].map(\.value).reduce(0, +) / total
                        )
                        .stroke(segments[index].color, lineWidth: 10)
                        .rotationEffect(.degrees(-90))
                }
            }
            .frame(width: 120, height: 120)
            
            // Legend
            VStack(alignment: .leading) {
                ForEach(segments.indices, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(segments[index].color)
                            .frame(width: 8, height: 8)
                        Text(segments[index].label)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
