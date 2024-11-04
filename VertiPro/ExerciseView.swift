import SwiftUI

struct ExerciseView: View {
    // Parameters passed from ExerciseSetupView
    let dizzinessLevel: Double
    let speed: Double
    let headMovement: String
    let duration: Int
    
    // State Management
    @StateObject private var motionManager = MotionManager()
    @State private var score: Int = 0
    @State private var timerValue: Int
    @State private var isExerciseActive = false
    @State private var shouldNavigateToResults = false
    @State private var session: ExerciseSession?
    @State private var sessionMovements: [Movement] = []
    @State private var targetAppearanceTime: Date = Date()
    @State private var totalTargets: Int = 0
    @State private var isDeviceMoving = false
    
    // Add environment variable for dismissing
    @Environment(\.dismiss) private var dismiss
    
    init(dizzinessLevel: Double, speed: Double, headMovement: String, duration: Int) {
        self.dizzinessLevel = dizzinessLevel
        self.speed = speed
        self.headMovement = headMovement
        self.duration = duration
        _timerValue = State(initialValue: duration)
    }
    
    var body: some View {
        ZStack {
            CameraView()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Custom back button at the top
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
                    .opacity(isExerciseActive ? 0 : 1) // Hide during exercise
                    
                    Spacer()
                }
                .padding(.top, 10)
                
                Text("Current Direction: \(motionManager.currentDirection.rawValue)")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
                
                Spacer()
                
                // Arrow
                ArrowView(direction: motionManager.currentDirection)
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
        .fullScreenCover(isPresented: $shouldNavigateToResults) {
            if let session = session {
                ResultsView(session: session)
            }
        }
    }
    
    private func position(for direction: Direction) -> CGPoint {
        let screen = UIScreen.main.bounds
        let center = CGPoint(x: screen.midX, y: screen.midY)
        let offset: CGFloat = 100
        
        switch direction {
        case .up:
            return CGPoint(x: center.x, y: center.y - offset)
        case .down:
            return CGPoint(x: center.x, y: center.y + offset)
        case .left:
            return CGPoint(x: center.x - offset, y: center.y)
        case .right:
            return CGPoint(x: center.x + offset, y: center.y)
        }
    }
    
    private func startExercise() {
        isExerciseActive = true
        score = 0
        timerValue = duration
        sessionMovements = []
        totalTargets = 0
        targetAppearanceTime = Date()
        
        motionManager.onDirectionChanged = { newDirection in
            score += 1
            let movement = Movement(
                direction: motionManager.currentDirection,
                responseTime: Date().timeIntervalSince(targetAppearanceTime),
                timestamp: Date()
            )
            sessionMovements.append(movement)
            totalTargets += 1
            targetAppearanceTime = Date()
        }
        
        motionManager.onDeviceMoving = { isMoving in
            isDeviceMoving = isMoving
        }
        
        motionManager.startMotionDetection()
        startTimer()
    }
    
    private func stopExercise() {
        isExerciseActive = false
        motionManager.stopMotionDetection()
        
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
    
    private var speedMultiplier: Double {
        switch speed {
        case 0: return 0.5  // Extra Slow
        case 1: return 0.75 // Slow
        case 2: return 1.0  // Normal
        case 3: return 1.25 // Fast
        case 4: return 1.5  // Extra Fast
        default: return 1.0
        }
    }
}

 
