//
//  ExerciseSetupView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

// ExerciseSetupView.swift
import SwiftUI

struct ExerciseSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dizzinessLevel = 5.0
    @State private var speed = 2.0
    @State private var headMovement = "All"
    @State private var duration = 30
    @State private var showingCountdown = false
    @State private var showExerciseView = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Close Button
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // Title
            Text("How dizzy you are feeling?")
                .font(.title2)
                .fontWeight(.bold)
            Text("On a scale from 1-10")
                .foregroundColor(.gray)
            
            // Dizziness Level Slider
            VStack(spacing: 10) {
                HStack {
                    ForEach(1...10, id: \.self) { number in
                        Text("\(number)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Slider(value: $dizzinessLevel, in: 1...10, step: 1)
                    .tint(dizzinessGradient)
            }
            .padding(.horizontal)
            
            // Speed Selection
            VStack(alignment: .leading, spacing: 15) {
                Text("Speed")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                HStack {
                    Text("Xt. Slow")
                    Spacer()
                    Text("Slow")
                    Spacer()
                    Text("Medium")
                    Spacer()
                    Text("Fast")
                    Spacer()
                    Text("Xt. Fast")
                }
                .font(.caption)
                .foregroundColor(.gray)
                
                Slider(value: $speed, in: 0...4, step: 1)
                    .tint(.blue)
            }
            .padding(.horizontal)
            
            // Head Movement Selection
            VStack(alignment: .leading, spacing: 15) {
                Text("Head Movement")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Picker("Head Movement", selection: $headMovement) {
                    Text("All").tag("All")
                    Text("Up & Down").tag("Up & Down")
                    Text("Left & Right").tag("Left & Right")
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            // Exercise Mode Selection
            VStack(alignment: .leading, spacing: 15) {
                Text("Exercise Mode")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Picker("Duration", selection: $duration) {
                    Text("30 Seconds").tag(30)
                    Text("60 Seconds").tag(60)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Start Button
            Button(action: { showingCountdown = true }) {
                Text("Ok")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(width: 60, height: 60)
                    .background(Circle().stroke(Color.gray, lineWidth: 1))
            }
            .padding(.bottom)
        }
        .navigationBarHidden(true)
        // First show countdown
        .fullScreenCover(isPresented: $showingCountdown) {
            CountdownView(
                headMovement: headMovement,
                isCountdownComplete: $showExerciseView,
                onDismiss: {
                    showingCountdown = false
                    showExerciseView = false
                }
            )
            .onChange(of: showExerciseView) { newValue in
                if newValue {
                    showingCountdown = false  // Dismiss countdown when exercise starts
                }
            }
        }
        // Then show exercise
        .fullScreenCover(isPresented: $showExerciseView) {
            ExerciseView(
                dizzinessLevel: dizzinessLevel,
                speed: speed,
                headMovement: headMovement,
                duration: duration,
                onDismiss: {
                    showingCountdown = false
                    showExerciseView = false
                }
            )
        }
    }
    
    private var dizzinessGradient: LinearGradient {
        LinearGradient(
            colors: [.green, .yellow, .orange, .red],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    ExerciseSetupView()
}
