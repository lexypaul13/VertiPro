import ARKit
import simd

class HeadTrackingManager: NSObject, ObservableObject, ARSessionDelegate {
    @Published private(set) var currentDirection: Direction = .up
    @Published private(set) var isTracking = false
    
    var onDirectionChanged: ((Direction) -> Void)?
    
    private var lastDirection: Direction?
    private let movementThreshold: Float = 12.0
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
              let faceAnchor = anchors.first as? ARFaceAnchor,
              Date().timeIntervalSince(lastUpdateTime) >= minimumTimeBetweenUpdates else {
            return
        }
        
        let pitch = faceAnchor.transform.eulerAngles.x
        let yaw = faceAnchor.transform.eulerAngles.y
        
        let pitchDegrees = pitch * 180 / .pi
        let yawDegrees = yaw * 180 / .pi
        
        print("Pitch: \(pitchDegrees), Yaw: \(yawDegrees)")
        
        let newDirection: Direction?
        
        if abs(pitchDegrees) > abs(yawDegrees) {
            if pitchDegrees > movementThreshold {
                newDirection = .down
            } else if pitchDegrees < -movementThreshold {
                newDirection = .up
            } else {
                newDirection = nil
            }
        } else {
            if yawDegrees > movementThreshold {
                newDirection = .right
            } else if yawDegrees < -movementThreshold {
                newDirection = .left
            } else {
                newDirection = nil
            }
        }
        
        if let direction = newDirection, direction != lastDirection {
            print("Movement detected: \(direction)")
            DispatchQueue.main.async {
                self.currentDirection = direction
                self.onDirectionChanged?(direction)
                self.lastDirection = direction
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
