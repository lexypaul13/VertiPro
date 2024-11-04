import CoreMotion

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var currentDirection: Direction = .up
    
    // Configuration
    var speedMultiplier: Double = 1.0
    var allowedMovements: String = "All"
    
    // Callbacks
    var onDirectionChanged: ((Direction) -> Void)?
    var onDeviceMoving: ((Bool) -> Void)?
    
    // Adjusted thresholds
    private let yawThreshold: Double = 0.2
    private let pitchThreshold: Double = 0.2
    private let updateInterval: TimeInterval = 0.2
    private let deviceMovementThreshold: Double = 0.1
    private var lastUpdateTime: Date = Date()
    
    init() {
        setupMotionDetection()
    }
    
    func setupMotionDetection() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    }
    
    func startMotionDetection() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self,
                  let motion = motion,
                  Date().timeIntervalSince(self.lastUpdateTime) >= self.updateInterval else { return }
            
            // Get quaternion values for more accurate rotation
            let attitude = motion.attitude
            
            // Convert to euler angles
            let pitch = attitude.pitch
            let yaw = attitude.yaw
            let roll = attitude.roll
            
            print("Raw angles - Pitch: \(pitch), Yaw: \(yaw), Roll: \(roll)")
            
            var newDirection: Direction?
            
            // Check for head movements
            if abs(yaw) > self.yawThreshold {
                newDirection = yaw > 0 ? .left : .right
            } else if abs(pitch - .pi/2) > self.pitchThreshold {
                newDirection = pitch > .pi/2 ? .down : .up
            }
            
            if let newDirection = newDirection, newDirection != self.currentDirection {
                print("Direction changed to: \(newDirection.rawValue)")
                self.lastUpdateTime = Date()
                DispatchQueue.main.async {
                    self.currentDirection = newDirection
                    self.onDirectionChanged?(newDirection)
                }
            }
        }
    }
    
    func stopMotionDetection() {
        motionManager.stopDeviceMotionUpdates()
    }
} 
