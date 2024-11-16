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
        VStack(spacing: 0) {
            // Header
            Text("Exercise Summary")
                .font(.system(size: 34, weight: .bold))
                .padding(.top, 50)
                .padding(.bottom, 30)
            
            // Stats Cards Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ], spacing: 15) {
                // Date Card
                StatCard(
                    title: "Date",
                    value: session.date.formatted(date: .abbreviated, time: .shortened),
                    icon: "calendar",
                    color: .blue
                )
                
                // Duration Card
                StatCard(
                    title: "Duration",
                    value: "\(session.duration)s",
                    icon: "clock",
                    color: .green
                )
                
                // Score Card
                StatCard(
                    title: "Score",
                    value: "\(session.score)/\(session.totalTargets)",
                    icon: "target",
                    color: .orange
                )
                
                // Head Turns Card
                StatCard(
                    title: "Turns/Min",
                    value: String(format: "%.1f", session.headTurnsPerMinute),
                    icon: "arrow.left.arrow.right",
                    color: .purple
                )
                
                // Accuracy Card
                StatCard(
                    title: "Accuracy",
                    value: String(format: "%.0f%%", session.accuracy),
                    icon: "percent",
                    color: .pink
                )
                
                // Dizziness Card
                StatCard(
                    title: "Dizziness",
                    value: String(format: "%.1f", session.dizzinessLevel),
                    icon: "waveform.path",
                    color: .red
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Motivational Message
            VStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                    .padding(.bottom, 4)
                
                Text("Don't give up!")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Practice makes perfect.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 30)
            
            // Done Button
            Button {
                dataStore.addSession(session)
                dismiss()
            } label: {
                Text("Done")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

// Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Icon Circle
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                )
            
            // Title
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            // Value
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
    
    return ResultsView(session: sampleSession)
}

