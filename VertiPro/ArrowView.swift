//
//  ArrowView.swift
//  VertiPro
//
//  Created by Alex Paul on 11/4/24.
//

import SwiftUI

struct ArrowView: View {
    let direction: Direction
    
    var body: some View {
        ZStack {
            // Background circle for better visibility
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 70, height: 70)
            
            // Arrow
            Path { path in
                // Move arrow points slightly to make it more visible
                path.move(to: CGPoint(x: 25, y: 5))     // Top point
                path.addLine(to: CGPoint(x: 45, y: 45))  // Bottom right
                path.addLine(to: CGPoint(x: 5, y: 45))   // Bottom left
                path.closeSubpath()
            }
            .fill(Color.green)
            .rotationEffect(angle(for: direction))
        }
        .frame(width: 70, height: 70)
    }
    
    private func angle(for direction: Direction) -> Angle {
        switch direction {
        case .up: return .degrees(0)
        case .right: return .degrees(90)
        case .down: return .degrees(180)
        case .left: return .degrees(270)
        }
    }
} 
