import SwiftUI
import ARKit
import CoreMotion

// Enum to represent the directions


struct ExerciseView: View {
    // Parameters passed from ExerciseSetupView
    let dizzinessLevel: Double
    let speed: Double
    let headMovement: String
    let duration: Int
    
    // Game state properties
    @State private var currentTargetDirection: Direction = .left
    @State private var targetHit: Bool = false
    @State private var score: Int = 0
    @State private var timerValue: Int
    @State private var isExerciseActive = false
    @State private var shouldNavigateToResults = false
    @State private var session: ExerciseSession?
    
    // Core Motion properties
    private let motionManager = CMMotionManager()
    @State private var isDeviceMoving = false
    
    // Additional properties
    @State private var sessionMovements: [Movement] = []
    @State private var targetAppearanceTime: Date = Date()
    @State private var totalTargets: Int = 0
    
    init(dizzinessLevel: Double, speed: Double, headMovement: String, duration: Int) {
        self.dizzinessLevel = dizzinessLevel
        self.speed = speed
        self.headMovement = headMovement
        self.duration = duration
        _timerValue = State(initialValue: duration) // Initialize timerValue
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // AR content
                ARViewContainer(currentTargetDirection: $currentTargetDirection, targetHit: $targetHit)
                    .edgesIgnoringSafeArea(.all)
                
                // Overlay UI elements
                VStack {
                    HStack {
                        Text("Score: \(score)")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                        
                        Spacer()
                        
                        Text("Time Remaining: \(timerValue)s")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    Spacer()
                    
                    if !isExerciseActive {
                        Button(action: {
                            startExercise()
                        }) {
                            Text("Start")
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                        }
                    } else {
                        Button(action: {
                            stopExercise()
                        }) {
                            Text("Stop")
                                .fontWeight(.bold)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                        }
                    }
                }
                
                // Display message if device is moving
                if isDeviceMoving {
                    VStack {
                        Text("Please hold the device steady and move your head.")
                            .font(.headline)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .position(x: UIScreen.main.bounds.midX, y: 100)
                }
            }
            .onChange(of: currentTargetDirection) { newDirection in
                print("ExerciseView: currentTargetDirection changed to \(newDirection.rawValue)")
            }
            .onAppear {
                shouldNavigateToResults = false
                resetExercise()
            }
            
            .onDisappear {
                motionManager.stopDeviceMotionUpdates()
            }
            .navigationDestination(isPresented: $shouldNavigateToResults) {
                if let session = session {
                    ResultsView(session: session)
                } else {
                    Text("Exercise Complete! Your score: \(score)")
                }
            }
        }
    }
    
    // MARK: - Exercise Control Functions
    
    func startExercise() {
        isExerciseActive = true
        score = 0
        timerValue = duration
        showNextTarget()
        startMotionUpdates() // Add this line
        startTimer()
    }
    
    
    func stopExercise() {
        isExerciseActive = false
        motionManager.stopDeviceMotionUpdates()
        
        // Create an ExerciseSession object with detailed data
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
    
    func resetExercise() {
        isExerciseActive = false
        score = 0
        timerValue = duration
        currentTargetDirection = .left
        targetHit = false
        sessionMovements = []
        totalTargets = 0
    }
    
    // MARK: - Motion Updates and Head Movement Detection
    
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02 / speedMultiplier
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                guard let motion = motion, self.isExerciseActive else { return }
                
                self.checkDeviceMovement(motion: motion)
                
                let attitude = motion.attitude
                let pitch = attitude.pitch
                let yaw = attitude.yaw
                
                if self.isFacingTarget(pitch: pitch, yaw: yaw) {
                    if !self.targetHit {
                        self.targetHit = true
                        self.score += 1
                        
                        let responseTime = Date().timeIntervalSince(self.targetAppearanceTime)
                        
                        let movement = Movement(
                            direction: self.currentTargetDirection,
                            responseTime: responseTime,
                            timestamp: Date()
                        )
                        self.sessionMovements.append(movement)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 / self.speedMultiplier) {
                            self.showNextTarget()
                        }
                    }
                } else {
                    self.targetHit = false
                }
            }
        }
    }
    
    
    
    func checkDeviceMovement(motion: CMDeviceMotion) {
        let userAcceleration = motion.userAcceleration
        let threshold = 0.2 // Adjust based on sensitivity
        
        let accelerationMagnitude = sqrt(
            userAcceleration.x * userAcceleration.x +
            userAcceleration.y * userAcceleration.y +
            userAcceleration.z * userAcceleration.z
        )
        
        isDeviceMoving = accelerationMagnitude > threshold
    }
    
    func isFacingTarget(pitch: Double, yaw: Double) -> Bool {
        let tolerance = 0.2 // Radians, adjust for sensitivity
        print("Pitch: \(pitch), Yaw: \(yaw), Current Target: \(currentTargetDirection.rawValue)")
        
        switch currentTargetDirection {
        case .left:
            guard headMovement == "All" || headMovement == "Left & Right" else { return false }
            return abs(yaw) > tolerance && yaw < 0
        case .right:
            guard headMovement == "All" || headMovement == "Left & Right" else { return false }
            return abs(yaw) > tolerance && yaw > 0
        case .up:
            guard headMovement == "All" || headMovement == "Up & Down" else { return false }
            return abs(pitch) > tolerance && pitch < 0
        case .down:
            guard headMovement == "All" || headMovement == "Up & Down" else { return false }
            return abs(pitch) > tolerance && pitch > 0
        }
    }
    
    // MARK: - Target Management
    
    func showNextTarget() {
        
        let possibleDirections: [Direction]
        if headMovement == "All" {
            possibleDirections = Direction.allCases
        } else if headMovement == "Up & Down" {
            possibleDirections = [.up, .down]
        } else if headMovement == "Left & Right" {
            possibleDirections = [.left, .right]
        } else {
            possibleDirections = Direction.allCases
        }
        
        if let nextDirection = possibleDirections.randomElement() {
            DispatchQueue.main.async {
                self.currentTargetDirection = nextDirection
                print("Next target direction: \(self.currentTargetDirection.rawValue)")
            }
            targetHit = false
            targetAppearanceTime = Date()
            totalTargets += 1
        }
    }
    
    
    
    // MARK: - Timer Management
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.isExerciseActive {
                if self.timerValue > 0 {
                    self.timerValue -= 1
                } else {
                    timer.invalidate()
                    self.stopExercise()
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    // MARK: - Speed Multiplier
    
    var speedMultiplier: Double {
        switch speed {
        case 0:
            return 0.5 // Extra Slow
        case 1:
            return 0.75 // Slow
        case 2:
            return 1.0 // Normal
        case 3:
            return 1.25 // Fast
        case 4:
            return 1.5 // Extra Fast
        default:
            return 1.0 // Default to Normal
        }
    }
}


// MARK: - Results View (Optional)


