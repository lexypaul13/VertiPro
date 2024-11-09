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
        #if DEBUG
        loadHistoricalData()
        #else
        loadSessions()
        #endif
    }
    
    private func loadHistoricalData() {
        let calendar = Calendar.current
        let now = Date()
        
        // Create data starting from 4 months ago
        guard let startDate = calendar.date(byAdding: .month, value: -4, to: now) else { return }
        
        var sampleSessions: [ExerciseSession] = []
        var currentDate = startDate
        
        // Create a pattern of improvement over time
        while currentDate <= now {
            // Calculate progress factor (0.0 to 1.0) based on time elapsed
            let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
            let progressFactor = min(1.0, Double(daysSinceStart) / (120.0)) // 120 days = 4 months
            
            // More sessions on weekdays, fewer on weekends
            let weekday = calendar.component(.weekday, from: currentDate)
            let isWeekend = weekday == 1 || weekday == 7
            let sessionsToday = isWeekend ? 1 : Int.random(in: 2...3)
            
            // Create sessions for the day
            for sessionNum in 0..<sessionsToday {
                // Morning (8-10), Afternoon (12-2), Evening (5-7)
                let timeSlots = [(8,10), (12,14), (17,19)]
                let (startHour, endHour) = timeSlots[sessionNum % timeSlots.count]
                
                guard let sessionDate = calendar.date(
                    bySettingHour: Int.random(in: startHour...endHour),
                    minute: Int.random(in: 0...59),
                    second: 0,
                    of: currentDate
                ) else { continue }
                
                // Create movements with improving response times
                let baseResponseTime = max(0.5, 2.0 - (1.5 * progressFactor))
                let movements = (0..<Int.random(in: 15...25)).map { _ in
                    Movement(
                        direction: [Direction.up, .down, .left, .right].randomElement() ?? .up,
                        responseTime: Double.random(in: baseResponseTime...(baseResponseTime + 0.5)),
                        timestamp: sessionDate
                    )
                }
                
                // Accuracy improves over time with some variation
                let baseAccuracy = 60.0 + (25.0 * progressFactor)
                let dailyVariation = Double.random(in: -5.0...5.0)
                let sessionVariation = Double.random(in: -3.0...3.0)
                let accuracy = min(95.0, baseAccuracy + dailyVariation + sessionVariation)
                
                let totalTargets = movements.count
                let score = Int((accuracy * Double(totalTargets)) / 100.0)
                
                // Dizziness level decreases over time
                let baseDizziness = max(1.0, 8.0 - (5.0 * progressFactor))
                let dizziness = max(1.0, min(10.0, baseDizziness + Double.random(in: -1.0...1.0)))
                
                let session = ExerciseSession(
                    date: sessionDate,
                    duration: Int.random(in: 180...300), // 3-5 minutes
                    score: score,
                    totalTargets: totalTargets,
                    movements: movements,
                    dizzinessLevel: dizziness
                )
                
                sampleSessions.append(session)
            }
            
            // Move to next day
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        // Sort sessions by date
        sessions = sampleSessions.sorted { $0.date < $1.date }
        saveSessions()
    }
    
    func addSession(_ session: ExerciseSession) {
        sessions.append(session)
        saveSessions()
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "exerciseSessions")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "exerciseSessions"),
           let decoded = try? JSONDecoder().decode([ExerciseSession].self, from: data) {
            sessions = decoded
        }
    }
    
    #if DEBUG
    func clearAllData() {
        sessions = []
        saveSessions()
    }
    #endif
}


