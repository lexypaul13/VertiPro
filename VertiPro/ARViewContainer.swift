import SwiftUI
import ARKit
import SceneKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var currentTargetDirection: Direction
    @Binding var holdProgress: Double
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator
        
        // Configure AR session
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
        
        // Create and add arrow node
        if let arrowNode = context.coordinator.createArrowNode() {
            arView.scene.rootNode.addChildNode(arrowNode)
            context.coordinator.arrowNode = arrowNode // Store reference
            context.coordinator.updateTargets() // Initial position update
            print("Added arrow node.")
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.updateTargets()
    }
    func showNextTarget() {
        // Get current direction
        let current = currentTargetDirection
        
        // Get a new random direction that's different from the current one
        var newDirection: Direction
        repeat {
            newDirection = Direction.allCases.randomElement() ?? .left
        } while newDirection == current
        
        currentTargetDirection = newDirection
        print("Next target direction set to: \(currentTargetDirection.rawValue)")
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    
    
    
    
    
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARViewContainer
        var arrowNode: SCNNode?
        
        // Simplified thresholds
        private let threshold: Float = 0.15
        private let cooldown: TimeInterval = 0.5
        private var lastChangeTime = Date()
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
        }
        
        func createArrowNode() -> SCNNode? {
            // Create smaller arrow
            let plane = SCNPlane(width: 0.03, height: 0.03) // Smaller size
            let material = SCNMaterial()
            
            // Create bright green arrow
            let size = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let context = UIGraphicsGetCurrentContext()!
            
            context.setFillColor(UIColor.green.cgColor)
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 25, y: 5))
            path.addLine(to: CGPoint(x: 45, y: 45))
            path.addLine(to: CGPoint(x: 5, y: 45))
            path.close()
            
            context.addPath(path.cgPath)
            context.fillPath()
            
            let arrowImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            material.diffuse.contents = arrowImage
            material.isDoubleSided = true
            plane.materials = [material]
            
            let node = SCNNode(geometry: plane)
            // Position closer to face
            node.position = SCNVector3(0, 0, -0.15) // Much closer
            node.name = "arrow"
            
            return node
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let faceAnchor = frame.anchors.first as? ARFaceAnchor,
                  Date().timeIntervalSince(lastChangeTime) > cooldown else { return }
            
            // Get face orientation
            let lookAtPoint = faceAnchor.lookAtPoint
            
            // Check direction based on current target
            var directionAchieved = false
            
            switch parent.currentTargetDirection {
            case .left:
                directionAchieved = lookAtPoint.x > threshold
            case .right:
                directionAchieved = lookAtPoint.x < -threshold
            case .up:
                directionAchieved = lookAtPoint.y < -threshold
            case .down:
                directionAchieved = lookAtPoint.y > threshold
            }
            
            if directionAchieved {
                lastChangeTime = Date()
                DispatchQueue.main.async {
                    self.changeDirection()
                }
            }
        }
        
        private func changeDirection() {
            let current = parent.currentTargetDirection
            var newDirection: Direction
            repeat {
                newDirection = Direction.allCases.randomElement() ?? .left
            } while newDirection == current
            
            parent.currentTargetDirection = newDirection
            updateTargets()
        }
        
        func updateTargets() {
            guard let arrowNode = arrowNode else { return }
            
            let baseZ: Float = -0.15 // Closer to face
            let offset: Float = 0.05 // Smaller offset
            
            var position = SCNVector3(0, 0, baseZ)
            var rotation: Float = 0
            
            switch parent.currentTargetDirection {
            case .left:
                position = SCNVector3(-offset, 0, baseZ)
                rotation = Float.pi / 2
            case .right:
                position = SCNVector3(offset, 0, baseZ)
                rotation = -Float.pi / 2
            case .up:
                position = SCNVector3(0, offset, baseZ)
                rotation = 0
            case .down:
                position = SCNVector3(0, -offset, baseZ)
                rotation = Float.pi
            }
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            arrowNode.position = position
            arrowNode.eulerAngles.z = rotation
            SCNTransaction.commit()
        }
    }
    
    
    
    
}
extension Float {
    var radiansToDegrees: Float {
        return self * 180 / .pi
    }
}
extension ARFaceAnchor {
    var lookAtPoint: simd_float3 {
        return simd_float3(
            transform.columns.2.x,
            transform.columns.2.y,
            transform.columns.2.z
        )
    }
}
