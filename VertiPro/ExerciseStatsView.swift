import SwiftUI

struct ExerciseStatsView: View {
    let sessions: [ExerciseSession]
    
    private var exerciseModeCounts: (thirtySeconds: Int, sixtySeconds: Int) {
        let thirtySeconds = sessions.filter { $0.duration <= 30 }.count
        let sixtySeconds = sessions.filter { $0.duration > 30 }.count
        return (thirtySeconds, sixtySeconds)
    }
    
    private var headMovementCounts: (all: Int, upDown: Int, leftRight: Int) {
        let all = sessions.filter { session in
            session.movements.contains { $0.direction == .up || $0.direction == .down } &&
            session.movements.contains { $0.direction == .left || $0.direction == .right }
        }.count
        
        let upDown = sessions.filter { session in
            session.movements.contains { $0.direction == .up || $0.direction == .down } &&
            !session.movements.contains { $0.direction == .left || $0.direction == .right }
        }.count
        
        let leftRight = sessions.filter { session in
            !session.movements.contains { $0.direction == .up || $0.direction == .down } &&
            session.movements.contains { $0.direction == .left || $0.direction == .right }
        }.count
        
        return (all, upDown, leftRight)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                // Exercise Mode Frequency
                CircularChart(
                    title: "Exercise Mode\nFrequency",
                    segments: [
                        .init(value: Double(exerciseModeCounts.thirtySeconds), color: .cyan),
                        .init(value: Double(exerciseModeCounts.sixtySeconds), color: .blue)
                    ],
                    legend: [
                        .init(color: .cyan, label: "30 sec"),
                        .init(color: .blue, label: "60 sec")
                    ]
                )
                
                // Head Movement Frequency
                CircularChart(
                    title: "Head Movement\nFrequency",
                    segments: [
                        .init(value: Double(headMovementCounts.all), color: .blue),
                        .init(value: Double(headMovementCounts.upDown), color: .yellow),
                        .init(value: Double(headMovementCounts.leftRight), color: .cyan)
                    ],
                    legend: [
                        .init(color: .blue, label: "All"),
                        .init(color: .yellow, label: "Up & Down"),
                        .init(color: .cyan, label: "Left & Right")
                    ]
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct CircularChart: View {
    let title: String
    let segments: [Segment]
    let legend: [LegendItem]
    
    struct Segment {
        let value: Double
        let color: Color
    }
    
    struct LegendItem {
        let color: Color
        let label: String
    }
    
    private var total: Double {
        segments.map(\.value).reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
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
                }
            }
            .frame(width: 120, height: 120)
            .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<legend.count, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(legend[index].color)
                            .frame(width: 8, height: 8)
                        Text(legend[index].label)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ExerciseStatsView(sessions: [])
} 