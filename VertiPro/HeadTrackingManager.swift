import ARKit
import SwiftUICore
import simd

class HeadTrackingManager: NSObject, ObservableObject, ARSessionDelegate {
    @Published private(set) var currentDirection: Direction = .up
    @Published private(set) var isTracking = false
    @Published var movementAccuracy: Double = 0.0
    @Published var movementFeedback: MovementFeedback = .none
    
    enum MovementFeedback {
        case none
        case correct
        case borderline
        case incorrect
        
        var color: Color {
            switch self {
            case .none: return .clear
            case .correct: return .green.opacity(0.3)
            case .borderline: return .yellow.opacity(0.3)
            case .incorrect: return .red.opacity(0.3)
            }
        }
        
        var uiColor: UIColor {
            switch self {
            case .none: return .clear
            case .correct: return .systemGreen.withAlphaComponent(0.3)
            case .borderline: return .systemYellow.withAlphaComponent(0.3)
            case .incorrect: return .systemRed.withAlphaComponent(0.3)
            }
        }
    }
    
    var onDirectionChanged: ((Direction) -> Void)?
    
    private var lastDirection: Direction?
    private let centerThreshold: Double = 4.0
    private let correctThreshold: Double = 5.0
    private let warningThreshold: Double = 8.0
    private var lastUpdateTime = Date()
    private var centerStartTime: Date?
    private let minimumTimeBetweenUpdates: TimeInterval = 0.2
    private let centerHoldTime: TimeInterval = 0.3
    let session = ARSession()
    
    // Add these properties for tracking
    private var lastPitch: Double = 0.0
    private var lastYaw: Double = 0.0
    
    // Add MovementMetrics struct
    struct MovementMetrics {
        var speed: Double          // Current movement speed
        var precision: Double      // How precise the movement is
        var stability: Double      // How stable the movement is
        var returnTime: Double     // Time to return to center
        var quality: MovementQuality
    }
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    func startTracking() {
        guard !isTracking else { return }
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking not supported")
            return
        }
        
        DispatchQueue.main.async {
            self.isTracking = true
            self.lastDirection = nil
            
            let configuration = ARFaceTrackingConfiguration()
            self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    func stopTracking() {
        DispatchQueue.main.async {
            self.isTracking = false
            self.session.pause()
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard isTracking,
              let faceAnchor = anchors.first as? ARFaceAnchor else {
            return
        }
        
        let pitch = Double(faceAnchor.transform.eulerAngles.x)
        let yaw = Double(faceAnchor.transform.eulerAngles.y)
        
        let pitchDegrees = pitch * 180 / .pi
        let yawDegrees = yaw * 180 / .pi
        
        // Calculate movement metrics
        let metrics = calculateMovementMetrics(pitch: pitchDegrees, yaw: yawDegrees)
        
        // Update last values for next calculation
        lastPitch = pitchDegrees
        lastYaw = yawDegrees
        lastUpdateTime = Date()
        
        // Check for center position with new threshold
        let isInCenter = abs(pitchDegrees) < centerThreshold && abs(yawDegrees) < centerThreshold
        
        if isInCenter {
            if centerStartTime == nil {
                // Just entered center position
                centerStartTime = Date()
                print("🎯 Head entering center position")
            } else if Date().timeIntervalSince(centerStartTime!) >= centerHoldTime {
                // Held center position long enough
                if lastDirection != nil {
                    print("✅ Center position confirmed")
                    lastDirection = nil
                }
            }
        } else {
            centerStartTime = nil
            
            // Update feedback with enhanced metrics
            let (feedback, accuracy) = validateMovement(
                pitch: pitchDegrees,
                yaw: yawDegrees,
                targetDirection: currentDirection,
                metrics: metrics
            )
            
            // Update feedback immediately
            DispatchQueue.main.async {
                self.movementFeedback = feedback
                self.movementAccuracy = accuracy
            }
            
            // Only detect new movement if we don't have a last direction (came from center)
            guard lastDirection == nil else { return }
            
            // Log the dominant angle
            let dominantAngle = abs(pitchDegrees) > abs(yawDegrees) ? "Pitch" : "Yaw"
            print("🔍 Dominant movement: \(dominantAngle)")
            
            // Determine movement direction
            let newDirection: Direction?
            
            if abs(pitchDegrees) > abs(yawDegrees) {
                if pitchDegrees > correctThreshold {
                    newDirection = .up        // When pitch is positive (looking down), head is moving up
                    print("⬆️ Upward movement detected: \(String(format: "%.1f", pitchDegrees))°")
                } else if pitchDegrees < -correctThreshold {
                    newDirection = .down      // When pitch is negative (looking up), head is moving down
                    print("⬇️ Downward movement detected: \(String(format: "%.1f", pitchDegrees))°")
                } else {
                    newDirection = nil
                }
            } else {
                if yawDegrees > correctThreshold {
                    newDirection = .left      // When yaw is positive, head is moving left
                    print("⬅️ Leftward movement detected: \(String(format: "%.1f", yawDegrees))°")
                } else if yawDegrees < -correctThreshold {
                    newDirection = .right     // When yaw is negative, head is moving right
                    print("➡️ Rightward movement detected: \(String(format: "%.1f", yawDegrees))°")
                } else {
                    newDirection = nil
                }
            }
            
            if let direction = newDirection {
                print("🎯 Target Direction: \(currentDirection)")
                print("🔄 Movement detected: \(direction)")
                print("📊 Movement accuracy: \(Int(accuracy))%")
                
                DispatchQueue.main.async {
                    self.currentDirection = direction
                    self.onDirectionChanged?(direction)
                    self.lastDirection = direction
                }
            }
        }
    }
    
    func validateMovement(pitch: Double, yaw: Double, targetDirection: Direction, metrics: MovementMetrics) -> (MovementFeedback, Double) {
        let (angle, isCorrectAxis) = getRelevantAngle(pitch: pitch, yaw: yaw, for: targetDirection)
        
        if !isCorrectAxis {
            return (.incorrect, 0)
        }
        
        let accuracy = (1 - abs(angle) / correctThreshold) * 100
        
        if abs(angle) <= correctThreshold {
            return (.correct, min(100, accuracy))
        } else if abs(angle) <= warningThreshold {
            return (.borderline, max(0, accuracy))
        } else {
            return (.incorrect, max(0, accuracy))
        }
    }
    
    private func getRelevantAngle(pitch: Double, yaw: Double, for direction: Direction) -> (angle: Double, isCorrectAxis: Bool) {
        switch direction {
        case .up, .down:
            return (pitch, abs(pitch) > abs(yaw))
        case .left, .right:
            return (yaw, abs(yaw) > abs(pitch))
        }
    }
    
    private func calculateMovementMetrics(pitch: Double, yaw: Double) -> MovementMetrics {
        // Calculate speed from position changes
        let currentTime = Date()
        let deltaTime = currentTime.timeIntervalSince(lastUpdateTime)
        let speed = sqrt(pow(pitch - lastPitch, 2) + pow(yaw - lastYaw, 2)) / deltaTime
        
        // Calculate precision (how close to ideal path)
        let precision = calculatePrecision(pitch: pitch, yaw: yaw)
        
        // Calculate stability (how smooth the movement is)
        let stability = calculateStability(speed: speed)
        
        // Calculate return time to center
        let returnTime = calculateReturnTime()
        
        // Determine overall quality
        let quality = determineQuality(
            speed: speed,
            precision: precision,
            stability: stability
        )
        
        return MovementMetrics(
            speed: speed,
            precision: precision,
            stability: stability,
            returnTime: returnTime,
            quality: quality
        )
    }
    
    private func calculatePrecision(pitch: Double, yaw: Double) -> Double {
        // Calculate how close the movement is to the ideal path
        let idealAngle = getIdealAngle(for: currentDirection)
        let actualAngle = atan2(pitch, yaw) * 180 / .pi
        let angleDifference = abs(idealAngle - actualAngle)
        
        // Return precision score (0-100)
        return max(0, 100 - (angleDifference * 5))
    }
    
    private func calculateStability(speed: Double) -> Double {
        // Ideal speed ranges
        let minIdealSpeed = 10.0
        let maxIdealSpeed = 30.0
        
        if speed < minIdealSpeed {
            return max(0, speed / minIdealSpeed * 100)
        } else if speed > maxIdealSpeed {
            return max(0, 100 - ((speed - maxIdealSpeed) / maxIdealSpeed * 100))
        }
        return 100.0
    }
    
    private func calculateReturnTime() -> Double {
        // Time since last movement
        return Date().timeIntervalSince(lastUpdateTime)
    }
    
    private func determineQuality(speed: Double, precision: Double, stability: Double) -> MovementQuality {
        let overallScore = (speed + precision + stability) / 3
        
        switch overallScore {
        case 90...100: return .excellent
        case 70..<90: return .good
        case 50..<70: return .needsWork
        default: return .incorrect
        }
    }
    
    private func getIdealAngle(for direction: Direction) -> Double {
        switch direction {
        case .up: return 90
        case .down: return -90
        case .left: return 180
        case .right: return 0
        }
    }
}

extension simd_float4x4 {
    var eulerAngles: SIMD3<Float> {
        let pitch = asin(-self[2][0])
        let yaw = atan2(self[2][1], self[2][2])
        let roll = atan2(self[1][0], self[0][0])
        return SIMD3(pitch, yaw, roll)
    }
}

enum MovementQuality {
    case excellent   // Perfect form and timing
    case good        // Good form, slight timing off
    case needsWork   // Form needs improvement
    case incorrect   // Wrong movement pattern
    
    var description: String {
        switch self {
        case .excellent: return "Perfect form!"
        case .good: return "Good movement"
        case .needsWork: return "Adjust movement"
        case .incorrect: return "Incorrect pattern"
        }
    }
}
