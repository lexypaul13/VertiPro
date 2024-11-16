import SwiftUI

struct ExerciseView: View {
    // Keep existing parameters and state
    let dizzinessLevel: Double
    let speed: Double
    let headMovement: String
    let duration: Int
    let onDismiss: () -> Void
    
    // State Management
    @StateObject private var headTracker = HeadTrackingManager()
    @State private var score: Int = 0
    @State private var timerValue: Int
    @State private var isExerciseActive = false
    @State private var shouldNavigateToResults = false
    @State private var session: ExerciseSession?
    @State private var sessionMovements: [Movement] = []
    @State private var targetAppearanceTime: Date = Date()
    @State private var totalTargets: Int = 0
    @Environment(\.dismiss) private var dismiss
    @State private var currentTargetDirection: Direction = .up
    @State private var directionSequence: DirectionSequence?
    
    init(dizzinessLevel: Double, speed: Double, headMovement: String, duration: Int, onDismiss: @escaping () -> Void) {
        self.dizzinessLevel = dizzinessLevel
        self.speed = speed
        self.headMovement = headMovement
        self.duration = duration
        self.onDismiss = onDismiss
        _timerValue = State(initialValue: duration)
    }
    
    var body: some View {
        ZStack {
            // Camera background
            ARViewContainer(headTracker: headTracker)
                .edgesIgnoringSafeArea(.all)
            
            // Dark overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            // Main UI Content
            VStack {
                if !isExerciseActive {
                    // Back button when not active
                    HStack {
                        Button(action: {
                            onDismiss()
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                }
                
                // Status Bar
                HStack(spacing: 40) {
                    StatusItem(icon: "clock.fill", title: "Time", value: formatTime(timerValue))
                    StatusItem(icon: "star.fill", title: "Score", value: "\(score)")
                    StatusItem(icon: "target", title: "Targets", value: "\(totalTargets)")
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(.ultraThinMaterial.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                
                // Direction Circle
                ZStack {
                    // Dashed circle
                    Circle()
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 3,
                                dash: [10, 10]
                            )
                        )
                        .foregroundColor(
                            currentTargetDirection == headTracker.currentDirection ? .green : .white
                        )
                        .frame(width: 200, height: 200)
                    
                    // Direction indicator
                    Circle()
                        .fill(currentTargetDirection == headTracker.currentDirection ? Color.green : Color.white)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "arrow.up")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.black)
                                .rotationEffect(getRotationAngle(for: currentTargetDirection))
                        )
                }
                
                Spacer()
                
                // Start/Stop Button
                if !isExerciseActive {
                    Button(action: startExercise) {
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
                    .padding(.bottom, 16) // Reduced bottom padding to sit above tab bar
                } else {
                    Button(action: stopExercise) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Stop Exercise")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16) // Reduced bottom padding to sit above tab bar
                }
            }
        }
        .onAppear {
            headTracker.stopTracking()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                headTracker.startTracking()
            }
        }
        .onDisappear {
            headTracker.stopTracking()
        }
        .fullScreenCover(isPresented: $shouldNavigateToResults) {
            if let session = session {
                ResultsView(session: session)
            }
        }
    }
    
    private struct StatusItem: View {
        let icon: String
        let title: String
        let value: String
        
        var body: some View {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                    Text(title)
                        .foregroundColor(.gray)
                }
                .font(.caption)
                
                Text(value)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    // Keep existing helper functions and implementations
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func getRotationAngle(for direction: Direction) -> Angle {
        switch direction {
        case .up: return .degrees(0)
        case .right: return .degrees(90)
        case .down: return .degrees(180)
        case .left: return .degrees(270)
        }
    }
    
    // Keep existing exercise logic functions
    private func startExercise() {
        isExerciseActive = true
        score = 0
        timerValue = duration
        sessionMovements = []
        totalTargets = 0
        targetAppearanceTime = Date()
        
        directionSequence = DirectionSequence(headMovement: headMovement, speed: speed)
        
        headTracker.startTracking()
        
        headTracker.onDirectionChanged = { direction in
            if direction == self.currentTargetDirection {
                self.score += 1
                let movement = Movement(
                    direction: direction,
                    responseTime: Date().timeIntervalSince(self.targetAppearanceTime),
                    timestamp: Date()
                )
                self.sessionMovements.append(movement)
            }
        }
        
        startDirectionTimer()
        startTimer()
    }
    
    private func stopExercise() {
        isExerciseActive = false
        headTracker.stopTracking()
        
        let finalSession = ExerciseSession(
            date: Date(),
            duration: duration - timerValue,
            score: score,
            totalTargets: sessionMovements.count,
            movements: sessionMovements,
            dizzinessLevel: dizzinessLevel
        )
        
        ExerciseDataStore.shared.addSession(finalSession)
        session = finalSession
        shouldNavigateToResults = true
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if isExerciseActive {
                if timerValue > 0 {
                    timerValue -= 1
                } else {
                    timer.invalidate()
                    stopExercise()
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func startDirectionTimer() {
        guard let sequence = directionSequence else { return }
        
        func scheduleNextDirection() {
            guard isExerciseActive else { return }
            
            currentTargetDirection = sequence.getNextDirection()
            targetAppearanceTime = Date()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + sequence.directionDuration) {
                scheduleNextDirection()
            }
        }
        
        scheduleNextDirection()
    }
}

 
