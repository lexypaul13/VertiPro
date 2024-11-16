import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let headTracker: HeadTrackingManager
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var arView: ARSCNView?
        var arrowNode: SCNNode?
        let headTracker: HeadTrackingManager
        
        init(headTracker: HeadTrackingManager) {
            self.headTracker = headTracker
            super.init()
            setupArrowNode()
        }
        
        private func setupArrowNode() {
            // Create a simple arrow geometry (you can replace this with your custom arrow asset)
            let arrow = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
            arrowNode = SCNNode(geometry: arrow)
            
            // Set initial properties
            arrowNode?.position = SCNVector3(0, 0, -0.5)
            arrowNode?.scale = SCNVector3(0.05, 0.05, 0.05) // Smaller size
            
            // Add to scene
            if let arrowNode = arrowNode {
                arView?.scene.rootNode.addChildNode(arrowNode)
            }
        }
        
        func updateTargetPosition(_ direction: Direction) {
            guard let arrowNode = arrowNode else { return }
            
            DispatchQueue.main.async {
                // Base position
                var position = SCNVector3(0, 0, -0.5)
                let offset: Float = 0.3
                
                // Update position based on direction
                switch direction {
                case .up:
                    position.y += offset
                case .down:
                    position.y -= offset
                case .left:
                    position.x -= offset
                case .right:
                    position.x += offset
                }
                
                // Animate to new position
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.2
                arrowNode.position = position
                SCNTransaction.commit()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(headTracker: headTracker)
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        arView.session = headTracker.session
        arView.automaticallyUpdatesLighting = true
        
        // Store reference to view
        context.coordinator.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // No updates needed
    }
    
    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        coordinator.headTracker.stopTracking()
    }
}
