import SwiftUI
import Charts

struct DailyMovementTypeChart: View {
    let sessions: [ExerciseSession]
    
    private var movementTypeCounts: [MovementTypeCount] {
        var upDown = 0
        var leftRight = 0
        
        for session in sessions {
            for movement in session.movements {
                switch movement.direction {
                case .up, .down:
                    upDown += 1
                case .left, .right:
                    leftRight += 1
                }
            }
        }
        
        return [
            MovementTypeCount(type: "Up/Down", count: upDown),
            MovementTypeCount(type: "Left/Right", count: leftRight)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Movement Types")
                .font(.headline)
            
            Chart {
                ForEach(movementTypeCounts) { item in
                    BarMark(
                        x: .value("Type", item.type),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            .frame(height: 200)
            
            Text("Distribution of movement directions")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct MovementTypeCount: Identifiable {
    let id = UUID()
    let type: String
    let count: Int
}

//#Preview {
//    let sampleSessions = [
//        ExerciseSession(
//            date: Date(),
//            duration: 30,
//            movements: [
//                Movement(direction: .up, timestamp: Date()),
//                Movement(direction: .down, timestamp: Date()),
//                Movement(direction: .left, timestamp: Date())
//            ],
//            dizzinessLevel: 3
//        )
//    ]
//    
//    return DailyMovementTypeChart(sessions: sampleSessions)
//} 
