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
}


