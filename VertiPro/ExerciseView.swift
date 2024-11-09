import SwiftUI

struct ExerciseView: View {
    // Parameters passed from ExerciseSetupView
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
            
            // UI Overlay
            VStack {
                // Back button
                HStack {
                    Button(action: {
                        if !isExerciseActive {
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .padding(.leading)
                    }
                    .opacity(isExerciseActive ? 0 : 1)
                    
                    Spacer()
                }
                .padding(.top, 10)
                
                Text("Target Direction: \(currentTargetDirection.rawValue)")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                
                Spacer()
                
                // Arrow
                ArrowView(direction: currentTargetDirection)
                    .frame(width: 60, height: 60)
                
                Spacer()
                
                // Score and Timer
                HStack {
                    Text("Score: \(score)")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Time: \(timerValue)s")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                // Start/Stop Button
                Button(action: {
                    if isExerciseActive {
                        stopExercise()
                    } else {
                        startExercise()
                    }
                }) {
                    Text(isExerciseActive ? "Stop" : "Start")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // Clean up any existing session and start fresh
            headTracker.stopTracking()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                headTracker.startTracking()
            }
        }
        .onDisappear {
            // Ensure cleanup when view disappears
            headTracker.stopTracking()
        }
        .fullScreenCover(isPresented: $shouldNavigateToResults) {
            if let session = session {
                ResultsView(session: session)
                    .onDisappear {
                        // Reset tracking when returning from results
                        headTracker.stopTracking()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            headTracker.startTracking()
                        }
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Exit") {
                    onDismiss()
                    dismiss()
                }
            }
        }
    }
    
    private func startExercise() {
        headTracker.stopTracking()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            headTracker.startTracking()
        }
        
        isExerciseActive = true
        score = 0
        timerValue = duration
        sessionMovements = []
        totalTargets = 0
        targetAppearanceTime = Date()
        
        directionSequence = DirectionSequence(headMovement: headMovement, speed: speed)
        
        startDirectionTimer()
        
        headTracker.onDirectionChanged = { newDirection in
            if newDirection == currentTargetDirection {
                score += 1
                let movement = Movement(
                    direction: newDirection,
                    responseTime: Date().timeIntervalSince(targetAppearanceTime),
                    timestamp: Date()
                )
                sessionMovements.append(movement)
                totalTargets += 1
            }
        }
        
        startTimer()
    }
    
    private func stopExercise() {
        isExerciseActive = false
        
        session = ExerciseSession(
            date: Date(),
            duration: duration - timerValue,
            score: score,
            totalTargets: totalTargets,
            movements: sessionMovements,
            dizzinessLevel: dizzinessLevel
        )
        
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

 
