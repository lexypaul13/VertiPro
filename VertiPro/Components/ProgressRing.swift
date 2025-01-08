import SwiftUI

struct ProgressRing: View {
    let value: Double
    let total: Double
    let title: String
    let color: Color
    
    private var progress: Double {
        min(value / total, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)
                
                VStack(spacing: 4) {
                    Text("\(Int(value))")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80, height: 80)
        }
    }
} 