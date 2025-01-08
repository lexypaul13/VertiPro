import SwiftUI

struct ExerciseDetailView: View {
    let session: ExerciseSession
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Clinical Header
                ClinicalHeader(session: session)
                
                // Performance Overview
                SessionMetricsView(session: session)
                
                // Movement Analysis Card
                MovementAnalysisCard(session: session)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// Clinical Header Component
struct ClinicalHeader: View {
    let session: ExerciseSession
    
    var body: some View {
        VStack(spacing: 16) {
            // Session Info & Accuracy
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gaze Stabilization Exercise")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(session.date.formatted(date: .long, time: .shortened))
                        .font(.system(.subheadline, design: .rounded))
                }
                
                Spacer()
                
                // Enhanced Accuracy Badge
                AccuracyIndicator(accuracy: session.accuracy)
            }
            
            Divider()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// Session Metrics View Component
struct SessionMetricsView: View {
    let session: ExerciseSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Metrics")
                .font(.system(.title3, design: .rounded, weight: .semibold))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ClinicalMetricCard(
                    title: "Duration",
                    value: formatDuration(session.duration),
                    icon: "clock.fill",
                    color: .blue
                )
                
                ClinicalMetricCard(
                    title: "Score",
                    value: "\(session.score)/\(session.totalTargets)",
                    icon: "target",
                    color: .green
                )
                
                ClinicalMetricCard(
                    title: "Dizziness",
                    value: String(format: "%.1f", session.dizzinessLevel),
                    icon: "waveform.path.ecg",
                    color: .orange
                )
                
                ClinicalMetricCard(
                    title: "Turns/min",
                    value: String(format: "%.1f", session.headTurnsPerMinute),
                    icon: "arrow.triangle.2.circlepath",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes):\(String(format: "%02d", remainingSeconds))"
    }
}

// Movement Analysis Card Component
struct MovementAnalysisCard: View {
    let session: ExerciseSession
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Movement Analysis")
                .font(.system(.title3, design: .rounded, weight: .semibold))
            
            Picker("View", selection: $selectedTab) {
                Text("Distribution").tag(0)
                Text("Timeline").tag(1)
            }
            .pickerStyle(.segmented)
            
            if selectedTab == 0 {
                MovementDistributionView(movements: session.movements)
            } else {
                MovementTimelineView(movements: session.movements)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// Supporting Components
struct AccuracyIndicator: View {
    let accuracy: Double
    
    private var color: Color {
        switch accuracy {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
    
    private var performanceText: String {
        switch accuracy {
        case 80...100: return "Excellent"
        case 60..<80: return "Good"
        default: return "Needs Work"
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            // Accuracy percentage
            Text("\(Int(accuracy))%")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(color)
            
            // Performance label
            Text(performanceText)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(color)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 4)
                    
                    // Progress
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * accuracy / 100, height: 4)
                }
            }
            .frame(width: 80, height: 4)
        }
        .padding(.vertical, 4)
    }
}

struct ClinicalMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if icon == "waveform.path.ecg" {
                    Image("Dizzy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(colorScheme == .dark ? .white : color)
                } else if icon == "arrow.triangle.2.circlepath" {
                    Image("Four Way Direction")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(colorScheme == .dark ? .white : color)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colorScheme == .dark ? .white : color)
                }
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : color)
            }
            
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(colorScheme == .dark ? 0.2 : 0.1))
        .cornerRadius(12)
    }
}

// Movement Distribution View Component
struct MovementDistributionView: View {
    let movements: [Movement]
    
    private var directionStats: [(direction: Direction, count: Int, color: Color)] {
        let counts = Dictionary(grouping: movements, by: { $0.direction })
            .mapValues { $0.count }
        
        return [
            (direction: .up, count: counts[.up] ?? 0, color: .blue),
            (direction: .down, count: counts[.down] ?? 0, color: .green),
            (direction: .left, count: counts[.left] ?? 0, color: .orange),
            (direction: .right, count: counts[.right] ?? 0, color: .purple)
        ].sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(directionStats, id: \.direction) { stat in
                HStack(spacing: 12) {
                    // Direction Icon
                    ZStack {
                        Circle()
                            .fill(stat.color.opacity(0.2))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: directionIcon(stat.direction))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(stat.color)
                    }
                    
                    // Bar Chart
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.1))
                            
                            // Value bar
                            RoundedRectangle(cornerRadius: 6)
                                .fill(stat.color.opacity(0.3))
                                .frame(width: calculateWidth(
                                    count: stat.count,
                                    maxCount: directionStats.map(\.count).max() ?? 1,
                                    totalWidth: geometry.size.width
                                ))
                            
                            // Count label
                            HStack {
                                Text("\(stat.count) moves")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                        }
                    }
                    .frame(height: 32)
                }
            }
        }
    }
    
    private func calculateWidth(count: Int, maxCount: Int, totalWidth: CGFloat) -> CGFloat {
        guard maxCount > 0 else { return 0 }
        return totalWidth * CGFloat(count) / CGFloat(maxCount)
    }
    
    private func directionIcon(_ direction: Direction) -> String {
        switch direction {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
}

// Movement Timeline View Component
struct MovementTimelineView: View {
    let movements: [Movement]
    @State private var showingAllMovements = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Timeline header
            HStack {
                Text("Response Times")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Text("Most Recent First")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            // Timeline items
            ForEach(movements.prefix(6).indices, id: \.self) { index in
                TimelineItem(
                    movement: movements[index],
                    isLast: index == movements.prefix(6).count - 1
                )
            }
            
            if movements.count > 6 {
                Button(action: {
                    showingAllMovements = true
                }) {
                    Text("Show All Movements")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingAllMovements) {
            NavigationView {
                AllMovementsView(movements: movements)
            }
        }
    }
}

// New view for showing all movements
struct AllMovementsView: View {
    let movements: [Movement]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(movements.indices, id: \.self) { index in
                TimelineItem(
                    movement: movements[index],
                    isLast: true  // No dividers in list view
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .navigationTitle("All Movements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

// Timeline Item Component
struct TimelineItem: View {
    let movement: Movement
    let isLast: Bool
    
    private var responseTimeColor: Color {
        switch movement.responseTime {
        case ..<1.0: return .green
        case 1.0..<2.0: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Direction indicator
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: directionIcon(movement.direction))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Movement info
                HStack {
                    Text(movement.direction.rawValue)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                    
                    Text(movement.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // Response time
                Text(String(format: "Response: %.2fs", movement.responseTime))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(responseTimeColor)
            }
            
            Spacer()
        }
        
        if !isLast {
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 1)
                .padding(.leading, 56)
        }
    }
    
    private func directionIcon(_ direction: Direction) -> String {
        switch direction {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
}
