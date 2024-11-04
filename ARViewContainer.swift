class Coordinator: NSObject, ARSessionDelegate {
    // Constants for debugging and thresholds
    private let debugMode = true
    private let pitchThreshold: Float = 0.3
    private let yawThreshold: Float = 0.3
    private let holdDuration: TimeInterval = 0.5
    
    // State tracking
    private var lastSuccessfulDirection: Direction?
    private var directionStartTime: Date?
    private var lastDebugPrint = Date()
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let faceAnchor = frame.anchors.first as? ARFaceAnchor else { return }
        
        // Extract face orientation from transform matrix
        let transform = faceAnchor.transform
        let pitch = asin(transform.columns.2.y)  // Changed to use asin for proper angle calculation
        let yaw = atan2(transform.columns.2.x, transform.columns.2.z)
        
        // Debug printing (once per second)
        if debugMode && Date().timeIntervalSince(lastDebugPrint) >= 1.0 {
            print("Raw Transform: \(transform)")
            print("Calculated - Pitch: \(pitch.radiansToDegrees)°, Yaw: \(yaw.radiansToDegrees)°")
            print("Thresholds - Pitch: ±\(pitchThreshold.radiansToDegrees)°, Yaw: ±\(yawThreshold.radiansToDegrees)°")
            lastDebugPrint = Date()
        }
        
        let currentDirection = parent.currentTargetDirection
        var directionAchieved = false
        
        // Check direction achievement with clearer threshold checks
        switch currentDirection {
        case .up:
            directionAchieved = pitch < -pitchThreshold  // Looking up (negative pitch)
            if debugMode { print("Up check: \(pitch) < -\(pitchThreshold) = \(directionAchieved)") }
        case .down:
            directionAchieved = pitch > pitchThreshold   // Looking down (positive pitch)
            if debugMode { print("Down check: \(pitch) > \(pitchThreshold) = \(directionAchieved)") }
        case .left:
            directionAchieved = yaw > yawThreshold      // Looking left (positive yaw)
            if debugMode { print("Left check: \(yaw) > \(yawThreshold) = \(directionAchieved)") }
        case .right:
            directionAchieved = yaw < -yawThreshold     // Looking right (negative yaw)
            if debugMode { print("Right check: \(yaw) < -\(yawThreshold) = \(directionAchieved)") }
        }
        
        // Direction state management with improved logging
        if directionAchieved {
            if lastSuccessfulDirection != currentDirection {
                print("Direction achieved: \(currentDirection). Starting timer.")
                directionStartTime = Date()
                lastSuccessfulDirection = currentDirection
            } else if let startTime = directionStartTime {
                let holdTime = Date().timeIntervalSince(startTime)
                if holdTime >= holdDuration {
                    print("Direction \(currentDirection) held for \(holdTime) seconds. Advancing to next target.")
                    DispatchQueue.main.async {
                        self.parent.showNextTarget()
                    }
                    lastSuccessfulDirection = nil
                    directionStartTime = nil
                }
            }
        } else {
            if lastSuccessfulDirection != nil {
                print("Lost direction alignment for \(currentDirection)")
                lastSuccessfulDirection = nil
                directionStartTime = nil
            }
        }
    }
    
    // Add this method to your Coordinator class
    func verifyFaceTracking(_ transform: simd_float4x4) {
        let pitch = asin(transform.columns.2.y)
        let yaw = atan2(transform.columns.2.x, transform.columns.2.z)
        
        print("Face Orientation Test:")
        print("═══════════════════")
        print("Pitch: \(pitch.radiansToDegrees)° (negative = looking up)")
        print("Yaw: \(yaw.radiansToDegrees)° (positive = looking left)")
        print("Current thresholds: ±\(pitchThreshold.radiansToDegrees)°")
        print("═══════════════════")
    }
    
    func updateTargets() {
        guard let arrowNode = arrowNode else { return }
        
        DispatchQueue.main.async {
            // Base position - further away from face for better visibility
            var position = SCNVector3(0, 0, -0.5)
            let offset: Float = 0.3  // Increased offset for wider spacing
            
            // Reset rotation to face the user
            arrowNode.constraints = [SCNBillboardConstraint()]  // Makes arrow always face user
            
            switch self.parent.currentTargetDirection {
            case .left:
                position = SCNVector3(-offset, 0, -0.5)
            case .right:
                position = SCNVector3(offset, 0, -0.5)
            case .up:
                position = SCNVector3(0, offset, -0.5)
            case .down:
                position = SCNVector3(0, -offset, -0.5)
            }
            
            // Animate position change
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            arrowNode.position = position
            SCNTransaction.commit()
            
            print("Arrow updated to direction: \(self.parent.currentTargetDirection.rawValue)")
        }
    }
    
    func createArrowNode() -> SCNNode? {
        let arrowLength: CGFloat = 0.1
        let arrowWidth: CGFloat = 0.05
        
        let plane = SCNPlane(width: arrowLength, height: arrowLength)
        let material = SCNMaterial()
        
        // Create a more visible arrow
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw arrow with thicker lines
        context.setFillColor(UIColor.green.cgColor)
        context.setLineWidth(4.0)
        
        // Arrow shape
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 50, y: 10))
        path.addLine(to: CGPoint(x: 90, y: 50))
        path.addLine(to: CGPoint(x: 70, y: 50))
        path.addLine(to: CGPoint(x: 70, y: 90))
        path.addLine(to: CGPoint(x: 30, y: 90))
        path.addLine(to: CGPoint(x: 30, y: 50))
        path.addLine(to: CGPoint(x: 10, y: 50))
        path.close()
        
        context.addPath(path.cgPath)
        context.fillPath()
        
        let arrowImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        material.diffuse.contents = arrowImage
        material.isDoubleSided = true
        plane.materials = [material]
        
        let node = SCNNode(geometry: plane)
        node.position = SCNVector3(0, 0, -0.5)  // Start further away
        node.name = "arrow"
        
        return node
    }
}

// Add this extension for angle conversion
extension Float {
    var radiansToDegrees: Float {
        return self * 180 / .pi
    }
} 