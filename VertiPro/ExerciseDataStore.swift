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
    private let sessionsKey = "exerciseSessions"
    
    private init() {
        loadSessions()
        
        if sessions.isEmpty {
            loadHistoricalData()
            saveSessions()
        }
    }
    
    func clearAndReloadData() {
        sessions = []
        loadHistoricalData()
        saveSessions()
        print("Data cleared and reloaded")
    }
    
    private func loadHistoricalData() {
        let calendar = Calendar.current
        let now = Date()
        
        // Create data starting from 4 months ago
        guard let startDate = calendar.date(byAdding: .month, value: -4, to: now) else { return }
        
        var sampleSessions: [ExerciseSession] = []
        var currentDate = startDate
        
        while currentDate <= now {
            // 1-2 sessions per day for smoother data
            let sessionsToday = Int.random(in: 1...2)
            
            for _ in 0..<sessionsToday {
                // Alternate between 30s and 60s sessions
                let duration = Bool.random() ? 30 : 60
                
                // Create movements based on random exercise type
                let exerciseType = Int.random(in: 0...2) // 0: All, 1: Up/Down, 2: Left/Right
                var movements: [Movement] = []
                
                let movementCount = duration == 30 ? Int.random(in: 8...12) : Int.random(in: 16...24)
                
                for _ in 0..<movementCount {
                    let direction: Direction
                    switch exerciseType {
                    case 0: // All movements
                        direction = [Direction.up, .down, .left, .right].randomElement()!
                    case 1: // Up/Down only
                        direction = Bool.random() ? .up : .down
                    case 2: // Left/Right only
                        direction = Bool.random() ? .left : .right
                    default:
                        direction = .up
                    }
                    
                    movements.append(Movement(
                        direction: direction,
                        responseTime: Double.random(in: 0.7...1.3),
                        timestamp: currentDate
                    ))
                }
                
                // Calculate score and accuracy
                let totalTargets = movements.count
                let score = Int.random(in: (totalTargets * 2 / 3)...totalTargets)
                
                let session = ExerciseSession(
                    date: currentDate,
                    duration: duration,
                    score: score,
                    totalTargets: totalTargets,
                    movements: movements,
                    dizzinessLevel: Double.random(in: 2...8)
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
        print("Session added. Total sessions: \(sessions.count)")
    }
    
    private func saveSessions() {
        do {
            let encoded = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
            print("Sessions saved successfully")
        } catch {
            print("Error saving sessions: \(error)")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey) {
            do {
                sessions = try JSONDecoder().decode([ExerciseSession].self, from: data)
                print("Loaded \(sessions.count) sessions")
            } catch {
                print("Error loading sessions: \(error)")
                sessions = []
            }
        }
    }
    
    // Add data cleanup
    func cleanupOldSessions(olderThan days: Int = 365) {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else { return }
        
        let oldCount = sessions.count
        sessions = sessions.filter { $0.date > cutoffDate }
        saveSessions()
        
        print("Cleaned up \(oldCount - sessions.count) old sessions")
    }
}


