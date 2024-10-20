//
//  ProgressCircleView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import SwiftUI


struct ProgressCircleView: View {
    let title: String
    let progress: Double
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.linear, value: progress)
                
                Text(String(format: "%.0f%%", min(progress, 1.0) * 100.0))
                    .font(.title2)
                    .bold()
                    .foregroundColor(.blue)
            }
            Text(title)
                .font(.headline)
        }
        .padding()
    }
}
#Preview {
    ProgressCircleView(title: "Test", progress: 0)
}
