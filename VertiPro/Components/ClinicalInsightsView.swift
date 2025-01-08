import SwiftUI

struct ClinicalInsightsView: View {
    let sessions: [ExerciseSession]
    
    private var insights: [String] {
        var results: [String] = []
        
        // Calculate trends and insights
        if let lastSession = sessions.last {
            if lastSession.accuracy > 80 {
                results.append("Excellent accuracy in latest session")
            }
            
            if lastSession.dizzinessLevel < 3 {
                results.append("Low dizziness levels maintained")
            }
        }
        
        // Add more insights based on data analysis
        return results
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Clinical Insights")
                .font(.title3.weight(.semibold))
            
            if insights.isEmpty {
                Text("Complete more sessions to generate insights")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(insights, id: \.self) { insight in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(insight)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
} 