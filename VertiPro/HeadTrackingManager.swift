import ARKit
import simd

class HeadTrackingManager: NSObject, ObservableObject, ARSessionDelegate {
    @Published var currentDirection: Direction = .up
    var onDirectionChanged: ((Direction) -> Void)?
    
    private let session = ARSession()
    private var lastUpdateTime = Date()
    private let minimumTimeBetweenUpdates = 0.5
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    func startTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device")
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        session.run(configuration)
    }
    
    func stopTracking() {
        session.pause()
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor,
              Date().timeIntervalSince(lastUpdateTime) >= minimumTimeBetweenUpdates else {
            return
        }
        
        // Create matrix from transform
        let matrix = simd_float4x4(
            faceAnchor.transform.columns.0,
            faceAnchor.transform.columns.1,
            faceAnchor.transform.columns.2,
            faceAnchor.transform.columns.3
        )
        
        let eulerAngles = simd_euler_angles_from_matrix(matrix)
        
        // Get pitch (x) and yaw (y) angles
        let pitch = eulerAngles.x
        let yaw = eulerAngles.y
        
        // Convert to degrees
        let pitchDegrees = pitch * 180 / .pi
        let yawDegrees = yaw * 180 / .pi
        
        // Determine new direction based on head movement
        let newDirection: Direction
        
        if abs(pitchDegrees) > abs(yawDegrees) {
            newDirection = pitchDegrees > 15 ? .down : (pitchDegrees < -15 ? .up : currentDirection)
        } else {
            newDirection = yawDegrees > 15 ? .right : (yawDegrees < -15 ? .left : currentDirection)
        }
        
        if newDirection != currentDirection {
            DispatchQueue.main.async {
                self.currentDirection = newDirection
                self.onDirectionChanged?(newDirection)
                self.lastUpdateTime = Date()
            }
        }
    }
}

// Helper function to extract euler angles from transform matrix
func simd_euler_angles_from_matrix(_ matrix: simd_float4x4) -> simd_float3 {
    let pitch = asin(-matrix[2][0])
    let yaw = atan2(matrix[2][1], matrix[2][2])
    let roll = atan2(matrix[1][0], matrix[0][0])
    return simd_float3(pitch, yaw, roll)
}
