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
        Path { path in
            path.move(to: CGPoint(x: 25, y: 0))
            path.addLine(to: CGPoint(x: 50, y: 50))
            path.addLine(to: CGPoint(x: 0, y: 50))
            path.closeSubpath()
        }
        .fill(Color.green)
        .rotationEffect(angle(for: direction))
    }
    
    private func angle(for direction: Direction) -> Angle {
        switch direction {
        case .up: return .degrees(0)
        case .down: return .degrees(180)
        case .left: return .degrees(-90)
        case .right: return .degrees(90)
        }
    }
}
