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
    private let correctThreshold: Double = 12.0
    private let warningThreshold: Double = 8.0
    private var lastUpdateTime = Date()
    private let minimumTimeBetweenUpdates: TimeInterval = 0.3
    let session = ARSession()
    
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
        
        // Print angles for debugging
        print("📐 Pitch: \(String(format: "%.1f", pitchDegrees))°, Yaw: \(String(format: "%.1f", yawDegrees))°")
        
        // Add this debug print
        print("\n--- Movement Update ---")
        print("Raw angles - Pitch: \(String(format: "%.1f", pitchDegrees))°, Yaw: \(String(format: "%.1f", yawDegrees))°")
        
        if abs(pitchDegrees) > abs(yawDegrees) {
            print("Dominant axis: Pitch (Up/Down)")
        } else {
            print("Dominant axis: Yaw (Left/Right)")
        }
        
        // First, validate the movement
        let (feedback, accuracy) = validateMovement(
            pitch: pitchDegrees,
            yaw: yawDegrees,
            targetDirection: currentDirection
        )
        
        // Update feedback immediately
        DispatchQueue.main.async {
            self.movementFeedback = feedback
            self.movementAccuracy = accuracy
        }
        
        // Check for center position
        if abs(pitchDegrees) < warningThreshold && abs(yawDegrees) < warningThreshold {
            if lastDirection != nil {  // Only print if coming from a movement
                print("🎯 Head returned to center")
            }
            lastDirection = nil
            return
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
    
    func validateMovement(pitch: Double, yaw: Double, targetDirection: Direction) -> (MovementFeedback, Double) {
        let (angle, isCorrectAxis) = getRelevantAngle(pitch: pitch, yaw: yaw, for: targetDirection)
        
        if !isCorrectAxis {
            return (.incorrect, 0)
        }
        
        let accuracy = (1 - abs(angle) / correctThreshold) * 100
        
        if abs(angle) > correctThreshold {
            return (.incorrect, max(0, accuracy))
        } else if abs(angle) > warningThreshold {
            return (.borderline, max(0, accuracy))
        } else {
            return (.correct, min(100, accuracy))
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
}

extension simd_float4x4 {
    var eulerAngles: SIMD3<Float> {
        let pitch = asin(-self[2][0])
        let yaw = atan2(self[2][1], self[2][2])
        let roll = atan2(self[1][0], self[0][0])
        return SIMD3(pitch, yaw, roll)
    }
}
