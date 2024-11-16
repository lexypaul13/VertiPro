import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let headTracker: HeadTrackingManager
    @Binding var currentTargetDirection: Direction
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var arView: ARSCNView?
        var faceNode: SCNNode?
        var arrowNode: SCNNode?
        var feedbackNode: SCNNode?
        var accuracyLabel: UILabel?
        let headTracker: HeadTrackingManager
        
        init(headTracker: HeadTrackingManager) {
            self.headTracker = headTracker
            super.init()
            setupNodes()
        }
        
        private func setupNodes() {
            // Create face anchor node
            faceNode = SCNNode()
            
            // Setup arrow
            setupArrow()
            
            // Setup feedback node
            setupFeedbackNode()
            
            // Setup accuracy label
            setupAccuracyLabel()
            
            // Add nodes to face node
            if let arrowNode = arrowNode,
               let feedbackNode = feedbackNode {
                faceNode?.addChildNode(arrowNode)
                faceNode?.addChildNode(feedbackNode)
            }
        }
        
        private func setupArrow() {
            // Create a larger, more visible arrow
            let arrow = SCNCone(topRadius: 0, bottomRadius: 0.03, height: 0.08)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemBlue
            material.emission.contents = UIColor.systemBlue // Make it glow
            arrow.materials = [material]
            
            arrowNode = SCNNode(geometry: arrow)
            arrowNode?.position = SCNVector3(0, 0, -0.5)
            arrowNode?.scale = SCNVector3(0.5, 0.5, 0.5)
        }
        
        private func setupFeedbackNode() {
            let circle = SCNPlane(width: 0.2, height: 0.2)
            let material = SCNMaterial()
            material.isDoubleSided = true
            material.diffuse.contents = UIColor.white.withAlphaComponent(0.3)
            circle.materials = [material]
            
            feedbackNode = SCNNode(geometry: circle)
            feedbackNode?.position = SCNVector3(0, 0, -0.6)
            feedbackNode?.opacity = 0.7
        }
        
        private func setupAccuracyLabel() {
            accuracyLabel = UILabel()
            accuracyLabel?.textAlignment = .center
            accuracyLabel?.font = .systemFont(ofSize: 36, weight: .bold)
            accuracyLabel?.textColor = .white
            accuracyLabel?.layer.shadowColor = UIColor.black.cgColor
            accuracyLabel?.layer.shadowOffset = CGSize(width: 0, height: 2)
            accuracyLabel?.layer.shadowOpacity = 0.5
            accuracyLabel?.layer.shadowRadius = 4
        }
        
        func updateFeedback(_ feedback: HeadTrackingManager.MovementFeedback, accuracy: Double) {
            guard let feedbackNode = feedbackNode else { return }
            
            let uiColor: UIColor
            switch feedback {
            case .none:
                uiColor = .clear
            case .correct:
                uiColor = .systemGreen.withAlphaComponent(0.5)
            case .borderline:
                uiColor = .systemYellow.withAlphaComponent(0.5)
            case .incorrect:
                uiColor = .systemRed.withAlphaComponent(0.5)
            }
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            feedbackNode.geometry?.firstMaterial?.diffuse.contents = uiColor
            feedbackNode.opacity = feedback == .none ? 0.3 : 0.5
            SCNTransaction.commit()
            
            DispatchQueue.main.async {
                self.accuracyLabel?.text = "\(Int(accuracy))%"
                self.accuracyLabel?.textColor = uiColor
            }
        }
        
        func updateTargetPosition(_ direction: Direction) {
            guard let arrowNode = arrowNode else { return }
            
            var position = SCNVector3(0, 0, -0.5)
            let offset: Float = 0.2
            
            switch direction {
            case .up:
                position.y += offset
                arrowNode.eulerAngles = SCNVector3(Float.pi, 0, 0)
            case .down:
                position.y -= offset
                arrowNode.eulerAngles = SCNVector3(0, 0, 0)
            case .left:
                position.x -= offset
                arrowNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
            case .right:
                position.x += offset
                arrowNode.eulerAngles = SCNVector3(0, 0, -Float.pi / 2)
            }
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            arrowNode.position = position
            SCNTransaction.commit()
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            
            faceNode?.simdTransform = faceAnchor.transform
            
            if let camera = arView?.pointOfView {
                let lookAtConstraint = SCNLookAtConstraint(target: camera)
                lookAtConstraint.isGimbalLockEnabled = true
                arrowNode?.constraints = [lookAtConstraint]
                feedbackNode?.constraints = [lookAtConstraint]
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
        
        context.coordinator.arView = arView
        
        if let faceNode = context.coordinator.faceNode {
            arView.scene.rootNode.addChildNode(faceNode)
        }
        
        if let accuracyLabel = context.coordinator.accuracyLabel {
            arView.addSubview(accuracyLabel)
            accuracyLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                accuracyLabel.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
                accuracyLabel.bottomAnchor.constraint(equalTo: arView.bottomAnchor, constant: -50)
            ])
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.updateTargetPosition(currentTargetDirection)
        context.coordinator.updateFeedback(
            headTracker.movementFeedback,
            accuracy: headTracker.movementAccuracy
        )
    }
    
    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        coordinator.headTracker.stopTracking()
        coordinator.accuracyLabel?.removeFromSuperview()
    }
}
