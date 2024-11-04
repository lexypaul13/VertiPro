//
//  ExerciseSetupView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

// ExerciseSetupView.swift
import SwiftUI

struct ExerciseSetupView: View {
    @State private var dizzinessLevel = 5.0
    @State private var speed = 2.0
    @State private var headMovement = "All"
    @State private var duration = 30
    @State private var showingExercise = false

    var body: some View {
        VStack(spacing: 30) {
            // Dizziness Level Slider
            VStack(alignment: .leading) {
                Text("Current Dizziness Level: \(Int(dizzinessLevel))")
                    .font(.headline)
                Slider(value: $dizzinessLevel, in: 1...10, step: 1)
            }
            .padding(.horizontal)

            // Speed Slider
            VStack(alignment: .leading) {
                Text("Speed: \(speedDescription)")
                    .font(.headline)
                Slider(value: $speed, in: 0...4, step: 1)
            }
            .padding(.horizontal)

            // Head Movement Toggles
            VStack(alignment: .leading) {
                Text("Head Movement")
                    .font(.headline)
                Picker("Head Movement", selection: $headMovement) {
                    Text("All").tag("All")
                    Text("Up & Down").tag("Up & Down")
                    Text("Left & Right").tag("Left & Right")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal)

            // Exercise Duration Toggles
            VStack(alignment: .leading) {
                Text("Exercise Duration")
                    .font(.headline)
                Picker("Duration", selection: $duration) {
                    Text("30 seconds").tag(30)
                    Text("60 seconds").tag(60)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal)

            Spacer()

            // Begin Exercise NavigationLink
            Button("Start Exercise") {
                showingExercise = true
            }
            .fullScreenCover(isPresented: $showingExercise) {
                ExerciseView(
                    dizzinessLevel: dizzinessLevel,
                    speed: speed,
                    headMovement: headMovement,
                    duration: duration
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .navigationBarTitle("Exercise Setup", displayMode: .inline)
    }

    var speedDescription: String {
        switch speed {
        case 0:
            return "Xt. Slow"
        case 1:
            return "Slow"
        case 2:
            return "Normal"
        case 3:
            return "Fast"
        case 4:
            return "Xt. Fast"
        default:
            return "Normal"
        }
    }
}



#Preview {
    ExerciseSetupView()
}
