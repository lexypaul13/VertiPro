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
    @State private var showingStopConfirmation = false
    @State private var isPaused = false
    @State private var showingExitAlert = false
    
    // Change timer properties to @State
    @State private var mainTimer: Timer?
    @State private var directionTimer: Timer?
    @Environment(\.scenePhase) private var scenePhase
    
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
            // AR Camera View
            ARViewContainer(
                headTracker: headTracker,
                currentTargetDirection: $currentTargetDirection
            )
            .edgesIgnoringSafeArea(.all)
            
            // Main Content Overlay
            VStack(spacing: 0) {
                // Add back button at the top
                HStack {
                    Button(action: { showingExitAlert = true }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                    .padding()
                    
                    Spacer()
                }
                
                // Status Bar
                StatusBar(
                    time: timerValue,
                    score: score,
                    targets: totalTargets
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
                // Movement Guide
                MovementGuideView(
                    currentDirection: currentTargetDirection,
                    accuracy: headTracker.movementAccuracy
                )
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Stop/Resume Button
                if isPaused {
                    HStack(spacing: 20) {
                        Button(action: resumeExercise) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Resume")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .clipShape(Capsule())
                        }
                        
                        Button(action: endExercise) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("End")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                } else {
                    StopButton {
                        showingStopConfirmation = true
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
        }
        .onAppear {
            startExercise()
        }
        .confirmationDialog(
            "Stop Exercise?",
            isPresented: $showingStopConfirmation,
            titleVisibility: .visible
        ) {
            Button("Pause", role: .none) {
                pauseExercise()
            }
            Button("End Exercise", role: .destructive) {
                endExercise()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Would you like to pause or end the exercise?")
        }
        .fullScreenCover(isPresented: $shouldNavigateToResults) {
            if let session = session {
                ResultsView(session: session)
            }
        }
        .alert("Exit Exercise?", isPresented: $showingExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                cleanup()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to exit? Your progress will be lost.")
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                pauseExercise()
            }
        }
        .onDisappear {
            cleanup()
        }
    }
    
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
    
    private func pauseExercise() {
        isPaused = true
        isExerciseActive = false
        headTracker.stopTracking()
    }
    
    private func resumeExercise() {
        isPaused = false
        isExerciseActive = true
        headTracker.startTracking()
        startDirectionTimer()
        startTimer()
    }
    
    private func endExercise() {
        stopExercise()
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
    
    private func startDirectionTimer() {
        directionTimer?.invalidate()
        
        guard let directionSequence = directionSequence else { return }
        currentTargetDirection = directionSequence.getNextDirection()
        
        directionTimer = Timer.scheduledTimer(withTimeInterval: directionSequence.directionDuration, repeats: true) { timer in
            guard isExerciseActive else {
                timer.invalidate()
                return
            }
            
            currentTargetDirection = directionSequence.getNextDirection()
            targetAppearanceTime = Date()
            totalTargets += 1
        }
    }
    
    private func startTimer() {
        mainTimer?.invalidate()
        
        mainTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard isExerciseActive else {
                timer.invalidate()
                return
            }
            
            if timerValue > 0 {
                timerValue -= 1
            } else {
                timer.invalidate()
                stopExercise()
            }
        }
    }
    
    private func cleanup() {
        mainTimer?.invalidate()
        directionTimer?.invalidate()
        headTracker.stopTracking()
        isExerciseActive = false
    }
}

// Status Bar Component
struct StatusBar: View {
    let time: Int
    let score: Int
    let targets: Int
    
    var body: some View {
        HStack {
            StatusItem(
                icon: "clock.fill",
                value: formatTime(time),
                label: "Time",
                color: .blue
            )
            
            Spacer()
            
            StatusItem(
                icon: "star.fill",
                value: "\(score)",
                label: "Score",
                color: .yellow
            )
            
            Spacer()
            
            StatusItem(
                icon: "target",
                value: "\(targets)",
                label: "Targets",
                color: .red
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// Status Item Component
struct StatusItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
            
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.gray)
        }
    }
}

// Movement Guide Component
struct MovementGuideView: View {
    let currentDirection: Direction
    let accuracy: Double
    
    var body: some View {
        ZStack {
            // Progress Circle
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.blue, .teal]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [1, 3]
                    )
                )
                .opacity(0.3)
            
            // Direction Arrow
            DirectionArrow(direction: currentDirection)
                .frame(width: 24, height: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Direction Arrow Component
struct DirectionArrow: View {
    let direction: Direction
    
    var body: some View {
        Image(systemName: "arrowtriangle.up.fill")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .teal],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .rotationEffect(angle(for: direction))
            .shadow(color: .blue.opacity(0.3), radius: 4)
    }
    
    private func angle(for direction: Direction) -> Angle {
        switch direction {
        case .up: return .degrees(0)
        case .right: return .degrees(90)
        case .down: return .degrees(180)
        case .left: return .degrees(270)
        }
    }
}

// Stop Button Component
struct StopButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Stop Exercise")
                    .font(.system(size: 18, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FF6B6B"), Color(hex: "FF6B6B").opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
        }
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

 
