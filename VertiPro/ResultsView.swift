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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Exercise Summary")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Metrics
            VStack(alignment: .leading, spacing: 10) {
                Text("Date: \(session.date.formatted(date: .abbreviated, time: .shortened))")
                Text("Duration: \(session.duration) seconds")
                Text("Score: \(session.score)")
                Text("Head Turns Per Minute: \(String(format: "%.1f", session.headTurnsPerMinute))")
                Text("Accuracy: \(String(format: "%.1f", session.accuracy))%")
                Text("Dizziness Level: \(session.dizzinessLevel)")
            }
            .font(.title2)
            .padding()

            // Encouraging Feedback
            Text(feedbackMessage)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()

            // Done Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue) // Use a color available in your project
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationBarTitle("Results", displayMode: .inline)
    }

    var feedbackMessage: String {
        if session.accuracy >= 90 {
            return "Excellent job! Keep up the great work!"
        } else if session.accuracy >= 75 {
            return "Good effort! You're improving!"
        } else {
            return "Don't give up! Practice makes perfect."
        }
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

