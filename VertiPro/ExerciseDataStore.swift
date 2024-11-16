//
//  ExerciseDataStore.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import Foundation
import Combine
import ARKit

class ExerciseDataStore: ObservableObject {
    static let shared = ExerciseDataStore()
    @Published var sessions: [ExerciseSession] = []
    
    private init() {
        loadSessions()
        if sessions.isEmpty {
            generateMockData()
        }
    }
    
    private func generateMockData() {
        sessions.removeAll()
        
        let calendar = Calendar.current
        let today = Date()
        
        // Generate data for past 90 days
        for dayOffset in 0..<90 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Get components for date-based variations
            let weekday = calendar.component(.weekday, from: date)
            let weekOfMonth = calendar.component(.weekOfMonth, from: date)
            let month = calendar.component(.month, from: date)
            
            // Number of sessions varies by day of week
            let sessionsCount = weekday <= 5 ? Int.random(in: 3...6) : Int.random(in: 1...3)
            
            // Generate sessions for this day
            for sessionNum in 0..<sessionsCount {
                // Create time components for the session
                let hour = Int.random(in: 9...17) // Sessions between 9 AM and 5 PM
                guard let sessionDate = calendar.date(bySettingHour: hour, minute: Int.random(in: 0...59), second: 0, of: date) else { continue }
                
                // Determine movement type based on desired distribution
                let movementType = Double.random(in: 0...100)
                let movementPattern: String
                if movementType < 70 {
                    movementPattern = "Left & Right"  // 70% chance
                } else if movementType < 90 {
                    movementPattern = "Up & Down"     // 20% chance
                } else {
                    movementPattern = "All"           // 10% chance
                }
                
                // Vary accuracy based on different factors
                let baseAccuracy = 75.0
                let weekdayBonus = Double(weekday) * 2.0
                let weeklyPattern = sin(Double(weekOfMonth) * .pi / 2.0) * 10.0
                let monthlyPattern = cos(Double(month) * .pi / 6.0) * 5.0
                let randomVariation = Double.random(in: -5.0...5.0)
                
                let targetAccuracy = baseAccuracy + weekdayBonus + weeklyPattern + monthlyPattern + randomVariation
                let clampedAccuracy = max(60.0, min(95.0, targetAccuracy))
                
                // Generate targets and score based on accuracy
                let targetCount = Int.random(in: 15...25)
                let score = Int((clampedAccuracy / 100.0) * Double(targetCount))
                
                // Create movements based on the pattern
                let movements = generateRandomMovements(
                    count: targetCount,
                    date: sessionDate,
                    accuracy: clampedAccuracy,
                    pattern: movementPattern
                )
                
                // Create session with varied duration
                let session = ExerciseSession(
                    date: sessionDate,
                    duration: [30, 60, 120][sessionNum % 3],
                    score: score,
                    totalTargets: targetCount,
                    movements: movements,
                    dizzinessLevel: Double.random(in: 2.0...8.0)
                )
                
                sessions.append(session)
            }
        }
        
        // Sort sessions by date
        sessions.sort { $0.date < $1.date }
        saveSessions()
        print("Generated \(sessions.count) mock sessions")
    }
    
    private func generateRandomMovements(count: Int, date: Date, accuracy: Double, pattern: String) -> [Movement] {
        var movements: [Movement] = []
        let calendar = Calendar.current
        
        // Define available directions based on pattern
        let directions: [Direction]
        switch pattern {
        case "Left & Right":
            directions = [.left, .right]
        case "Up & Down":
            directions = [.up, .down]
        default:
            directions = [.up, .down, .left, .right]
        }
        
        for i in 0..<count {
            // Create a pattern based on accuracy
            let usePattern = Double.random(in: 0...100) < accuracy
            let direction = usePattern ? directions[i % directions.count] : directions.randomElement()!
            
            // Add movement with timestamp spaced throughout the session
            if let movementTime = calendar.date(byAdding: .second, value: i * 3, to: date) {
                let movement = Movement(
                    direction: direction,
                    responseTime: Double.random(in: 0.5...2.0),
                    timestamp: movementTime
                )
                movements.append(movement)
            }
        }
        
        return movements
    }
    
    func clearAndReloadData() {
        sessions.removeAll()
        UserDefaults.standard.removeObject(forKey: "exerciseSessions")
        generateMockData()
    }
    
    func addSession(_ session: ExerciseSession) {
        sessions.append(session)
        saveSessions()
    }
    
    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: "exerciseSessions")
            print("Saved \(sessions.count) sessions")
        } catch {
            print("Error saving sessions: \(error)")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "exerciseSessions") {
            do {
                sessions = try JSONDecoder().decode([ExerciseSession].self, from: data)
                print("Loaded \(sessions.count) sessions")
            } catch {
                print("Error loading sessions: \(error)")
            }
        }
    }
}


