import ARKit
import simd

class HeadTrackingManager: NSObject, ObservableObject, ARSessionDelegate {
    @Published var currentDirection: Direction = .up
    var onDirectionChanged: ((Direction) -> Void)?
    
    let session: ARSession = ARSession()
    
    private var lastUpdateTime = Date()
    private let minimumTimeBetweenUpdates = 0.3
    private let angleThreshold: Float = 5.0
    private var isTracking = false
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    func startTracking() {
        guard !isTracking else { return }
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device")
            return
        }
        
        isTracking = true
        
        // Configure and start AR session
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run session with configuration
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func stopTracking() {
        guard isTracking else { return }
        isTracking = false
        session.pause()
    }
    
    // ARSessionDelegate methods
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session failed: \(error.localizedDescription)")
        isTracking = false
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR Session was interrupted")
        isTracking = false
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR Session interruption ended")
        startTracking() // Restart tracking when interruption ends
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard isTracking,
              let faceAnchor = anchors.first as? ARFaceAnchor,
              Date().timeIntervalSince(lastUpdateTime) >= minimumTimeBetweenUpdates else {
            return
        }
        
        // Get euler angles directly from face anchor
        let pitch = faceAnchor.transform.eulerAngles.x
        let yaw = faceAnchor.transform.eulerAngles.y
        
        // Convert to degrees
        let pitchDegrees = pitch * 180 / .pi
        let yawDegrees = yaw * 180 / .pi
        
        // Print angles for debugging
        print("Pitch: \(pitchDegrees), Yaw: \(yawDegrees)")
        
        // Determine new direction based on head movement
        var newDirection = currentDirection
        
        // Check vertical movement first with more sensitive thresholds
        if abs(pitchDegrees) > angleThreshold {
            if pitchDegrees > angleThreshold {
                newDirection = .down
            } else if pitchDegrees < -angleThreshold {
                newDirection = .up
            }
        }
        // Then check horizontal movement
        else if abs(yawDegrees) > angleThreshold {
            if yawDegrees > angleThreshold {
                newDirection = .right
            } else if yawDegrees < -angleThreshold {
                newDirection = .left
            }
        }
        
        if newDirection != currentDirection {
            DispatchQueue.main.async {
                print("Direction changed to: \(newDirection)")
                self.currentDirection = newDirection
                self.onDirectionChanged?(newDirection)
                self.lastUpdateTime = Date()
            }
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
