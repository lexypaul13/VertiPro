//
//  ExerciseSession.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import Foundation
import SwiftUI
import AVFoundation

struct ExerciseSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var duration: Int // Duration in seconds
    var score: Int
    var totalTargets: Int
    var movements: [Movement]
    var dizzinessLevel: Double

    // Computed properties
    var headTurnsPerMinute: Double {
        let minutes = Double(duration) / 60.0
        return minutes > 0 ? Double(score) / minutes : 0
    }

    var accuracy: Double {
        let accuracy = Double(score) / Double(totalTargets) * 100
        return accuracy.isNaN ? 0 : accuracy
    }
}


struct Movement: Codable {
    var direction: Direction
    var responseTime: TimeInterval
    var timestamp: Date
}



// SampleData.swift

 
