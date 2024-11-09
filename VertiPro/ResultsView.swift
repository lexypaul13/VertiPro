//
//  ResultsView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//


// ResultsView.swift
import SwiftUI

struct ResultsView: View {
    let session: ExerciseSession
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataStore = ExerciseDataStore.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Exercise Summary")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 15) {
                Text("Date: \(session.date.formatted())")
                Text("Duration: \(session.duration) seconds")
                Text("Score: \(session.score)")
                Text("Head Turns Per Minute: \(String(format: "%.1f", session.headTurnsPerMinute))")
                Text("Accuracy: \(String(format: "%.1f", session.accuracy))%")
                Text("Dizziness Level: \(String(format: "%.1f", session.dizzinessLevel))")
            }
            .font(.title3)

            Text("Don't give up! Practice makes perfect.")
                .font(.headline)
                .padding(.top)

            Button("Done") {
                // Save the session to ExerciseDataStore
                dataStore.addSession(session)
                dismiss()
            }
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    let sampleMovements = [
        Movement(direction: .left, responseTime: 1.2, timestamp: Date()),
        Movement(direction: .right, responseTime: 1.0, timestamp: Date())
    ]

    let sampleSession = ExerciseSession(
        date: Date(),
        duration: 60,
        score: 2,
        totalTargets: 5,
        movements: sampleMovements,
        dizzinessLevel: 5
    )

    ResultsView(session: sampleSession)
}

