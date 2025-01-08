import SwiftUI
import Charts

struct EnhancedPieChart: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let data: [ChartData]
    let showPercentages: Bool
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemGray6) : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Chart(data) { item in
                SectorMark(
                    angle: .value(item.label, item.value),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(item.color.gradient)
                .annotation(position: .overlay) {
                    if showPercentages {
                        Text("\(Int(item.value))%")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
            }
            .frame(height: 150)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(data) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.color.gradient)
                            .frame(width: 8, height: 8)
                        Text(item.label)
                            .font(.caption)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(Int(item.value))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
        .shadow(
            color: colorScheme == .dark ? .clear : .black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 2
        )
    }
} 
