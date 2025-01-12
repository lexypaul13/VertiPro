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
    @State private var dizzinessLevel: Double = 5.0
    @State private var selectedSpeed = 1
    @State private var selectedMovement = 0
    @State private var selectedDuration = 0
    @State private var arrowSize: Double = 32
    
    private let speeds = ["Xt. Slow", "Slow", "Medium", "Fast", "Xt. Fast"]
    private let movements = [
        (title: "All", description: "Combined up/down and left/right"),
        (title: "Up & Down", description: "Vertical movements only"),
        (title: "Left & Right", description: "Horizontal movements only")
    ]
    private let durations = ["30 Seconds", "1 Minute", "2 Minutes"]
    private let arrowSizes = ["Small", "Medium", "Large"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Dizziness Level
                VStack(alignment: .leading, spacing: 8) {
                    Text("How dizzy you are feeling?")
                        .font(.title2)
                        .bold()
                    Text("On a scale from 1-10")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Slider(value: $dizzinessLevel, in: 1...10, step: 1)
                        .tint(.green)
                    
                    // Numbers below slider
                    HStack {
                        ForEach(1...10, id: \.self) { number in
                            Text("\(number)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // Speed
                VStack(alignment: .leading, spacing: 8) {
                    Text("Speed")
                        .font(.title2)
                        .bold()
                    
                    Picker("", selection: $selectedSpeed) {
                        ForEach(0..<speeds.count, id: \.self) { index in
                            Text(speeds[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // Arrow Size
                VStack(alignment: .leading, spacing: 8) {
                    Text("Arrow Size")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        ForEach(arrowSizes.indices, id: \.self) { index in
                            let size = Double(index + 1) * 24 // Maps to 24, 48, 72
                            VStack {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: size/2))
                                Text(arrowSizes[index])
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(arrowSize == size ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .onTapGesture {
                                withAnimation {
                                    arrowSize = size
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // Head Movement
                VStack(alignment: .leading, spacing: 8) {
                    Text("Head Movement")
                        .font(.title2)
                        .bold()
                    
                    ForEach(movements.indices, id: \.self) { index in
                        Button {
                            selectedMovement = index
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(movements[index].title)
                                        .font(.headline)
                                    Text(movements[index].description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedMovement == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(selectedMovement == index ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 8)
                
                Divider()
                
                // Exercise Mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise Mode")
                        .font(.title2)
                        .bold()
                    
                    Picker("", selection: $selectedDuration) {
                        ForEach(0..<durations.count, id: \.self) { index in
                            Text(durations[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 8)
                                
                // Start Exercise Button
                Button {
                    let exerciseView = ExerciseView(
                        dizzinessLevel: dizzinessLevel,
                        speed: getSpeedValue(),
                        headMovement: movements[selectedMovement].title,
                        duration: getDurationValue(),
                        arrowSize: arrowSize,
                        onDismiss: { dismiss() }
                    )
                    
                    let hostingController = UIHostingController(rootView: exerciseView)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        hostingController.modalPresentationStyle = .fullScreen
                        rootViewController.present(hostingController, animated: true)
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Exercise")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
                }
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(false)
    }
    
    private func getDurationValue() -> Int {
        switch selectedDuration {
        case 0: return 30   // 30 seconds
        case 1: return 60   // 1 minute
        case 2: return 120  // 2 minutes
        default: return 60
        }
    }
    
    private func getSpeedValue() -> Double {
        switch selectedSpeed {
        case 0: return 0.5  // Xt. Slow
        case 1: return 1.0  // Slow
        case 2: return 1.5  // Medium
        case 3: return 2.0  // Fast
        case 4: return 2.5  // Xt. Fast
        default: return 1.5 // Medium (default)
        }
    }
}

#Preview {
    ExerciseSetupView()
}
