//
//  ExerciseSetupView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

// ExerciseSetupView.swift
import SwiftUI
import ARKit

struct ExerciseSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var dizzinessLevel = 5.0
    @State private var speed = 2.0
    @State private var headMovement = "All"
    @State private var duration = 30
    @State private var showingCountdown = false
    @State private var showExerciseView = false
    @State private var isNavigating = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let durations = [
        (seconds: 30, label: "30 Seconds"),
        (seconds: 60, label: "1 Minute"),
        (seconds: 120, label: "2 Minutes")
    ]
    
    var body: some View {
        VStack(spacing: 30) {
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
                            .foregroundColor(number == Int(dizzinessLevel) ? .primary : .gray)
                            .frame(maxWidth: .infinity)
                            .scaleEffect(number == Int(dizzinessLevel) ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: dizzinessLevel)
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
                    ForEach(["Xt. Slow", "Slow", "Medium", "Fast", "Xt. Fast"], id: \.self) { label in
                        Text(label)
                            .font(.caption)
                            .foregroundColor(speedLabel == label ? .primary : .gray)
                            .scaleEffect(speedLabel == label ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: speed)
                            .frame(maxWidth: .infinity)
                    }
                }
                
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
                    ForEach(durations, id: \.seconds) { duration in
                        Text(duration.label).tag(duration.seconds)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Start Button
            Button(action: {
                showingCountdown = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Start Exercise")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 80) // Adjusted to sit above tab bar
            .navigationBarBackButtonHidden(isNavigating)
            .fullScreenCover(isPresented: $showingCountdown) {
                CountdownView(
                    headMovement: headMovement,
                    isCountdownComplete: $showExerciseView,
                    onDismiss: { 
                        showingCountdown = false
                        showExerciseView = false
                        isNavigating = false
                    }
                )
            }
            .fullScreenCover(isPresented: $showExerciseView) {
                ExerciseView(
                    dizzinessLevel: dizzinessLevel,
                    speed: speed,
                    headMovement: headMovement,
                    duration: duration,
                    onDismiss: { handleDismiss() }
                )
            }
            .alert("Exercise Setup", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                checkDeviceCapabilities()
            }
        }
    }
    
    private func handleDismiss() {
        isNavigating = false
        showingCountdown = false
        showExerciseView = false
    }

    
    private func checkDeviceCapabilities() {
        if !ARFaceTrackingConfiguration.isSupported {
            alertMessage = "This device doesn't support face tracking."
            showAlert = true
        }
        
        // Check camera permissions
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                DispatchQueue.main.async {
                    alertMessage = "Camera access is required for exercises."
                    showAlert = true
                }
            }
        }
    }
    
    private func startExercise() {
        isNavigating = true
        showingCountdown = true
    }
    
    private var speedLabel: String {
        switch Int(speed) {
        case 0: return "Xt. Slow"
        case 1: return "Slow"
        case 2: return "Medium"
        case 3: return "Fast"
        case 4: return "Xt. Fast"
        default: return ""
        }
    }
    
    private var dizzinessGradient: LinearGradient {
        LinearGradient(
            colors: [
                .green,
                .green,
                .yellow,
                .yellow,
                .orange,
                .orange,
                .red,
                .red
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    ExerciseSetupView()
}
