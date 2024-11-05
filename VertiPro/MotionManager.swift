import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var currentDirection: Direction = .up
    var onDirectionChanged: ((Direction) -> Void)?
    var onDeviceMoving: ((Bool) -> Void)?
    
    private var lastUpdateTime = Date()
    private let minimumTimeBetweenUpdates = 0.5 // seconds
    
    func startMotionDetection() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz update rate
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Get pitch (up/down) and yaw (left/right) angles in radians
            let pitch = motion.attitude.pitch
            let yaw = motion.attitude.yaw
            
            // Convert to degrees for easier thresholds
            let pitchDegrees = pitch * 180 / .pi
            let yawDegrees = yaw * 180 / .pi
            
            // Determine the most prominent direction
            // Using smaller thresholds for more sensitive detection
            let newDirection: Direction
            
            if abs(pitchDegrees) > abs(yawDegrees) {
                newDirection = pitchDegrees > 10 ? .down : (pitchDegrees < -10 ? .up : self?.currentDirection ?? .up)
            } else {
                newDirection = yawDegrees > 10 ? .right : (yawDegrees < -10 ? .left : self?.currentDirection ?? .up)
            }
            
            // Only update if enough time has passed and direction has changed
            if let self = self,
               Date().timeIntervalSince(self.lastUpdateTime) >= self.minimumTimeBetweenUpdates,
               newDirection != self.currentDirection {
                
                DispatchQueue.main.async {
                    self.currentDirection = newDirection
                    self.onDirectionChanged?(newDirection)
                    self.lastUpdateTime = Date()
                }
            }
            
            // Detect if device is moving
            let isMoving = abs(motion.rotationRate.x) > 0.2 ||
                          abs(motion.rotationRate.y) > 0.2 ||
                          abs(motion.rotationRate.z) > 0.2
            
            DispatchQueue.main.async {
                self?.onDeviceMoving?(isMoving)
            }
        }
    }
    
    func stopMotionDetection() {
        motionManager.stopDeviceMotionUpdates()
    }
}

