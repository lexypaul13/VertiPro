import SwiftUI
import Charts

struct DailyMovementsChart: View {
    let sessions: [ExerciseSession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Movements")
                .font(.headline)
            
            Chart {
                ForEach(sessions) { session in
                    BarMark(
                        x: .value("Date", session.date),
                        y: .value("Movements", session.movements.count)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            .frame(height: 200)
            
            Text("Number of movements per session")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
} 