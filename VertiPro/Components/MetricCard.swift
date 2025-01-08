import SwiftUI
import Charts

// Add this struct for the chart data
struct DailyValue: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

struct MetricCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let value: String
    let change: Int
    let icon: String
    let color: Color
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemGray6) : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(.primary)
            
            if change != 0 {
                HStack(spacing: 4) {
                    Image(systemName: change > 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(abs(change)) from last period")
                        .font(.caption)
                }
                .foregroundColor(change > 0 ? .green : .red)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
        .shadow(
            color: colorScheme == .dark ? .clear : color.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

#Preview {
    MetricCard(
        title: "Total Sessions",
        value: "42",
        change: 5,
        icon: "figure.walk",
        color: .blue
    )
}

