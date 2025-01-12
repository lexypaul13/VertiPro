import SwiftUI
import ARKit

private struct MedicalStyle {
    // Professional Medical Color Scheme
    static let primaryBlue = UIColor(red: 44/255, green: 123/255, blue: 229/255, alpha: 1.0)
    static let secondaryTeal = UIColor(red: 37/255, green: 178/255, blue: 170/255, alpha: 1.0)
    
    // Feedback Colors
    static let successGreen = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0)
    static let cautionYellow = UIColor(red: 255/255, green: 185/255, blue: 70/255, alpha: 1.0)
    static let alertRed = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0)
    
    // Opacity Levels for Different Lighting
    static let darkModeOpacity: CGFloat = 0.7
    static let normalModeOpacity: CGFloat = 0.5
    static let brightModeOpacity: CGFloat = 0.6
    
    // Professional Dimensions
    static let borderWidth: CGFloat = 1.0
    static let cornerRadius: CGFloat = 12.0
    static let gridSpacing: CGFloat = 20.0
    
    // Warning Message Style
    static let warningBackground = UIColor(white: 0.1, alpha: 0.6)
    static let warningText = UIColor(white: 0.9, alpha: 0.9)
}

private struct AdaptiveStyle {
    // Base colors with higher saturation
    static let correctColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 0.8)
    static let warningColor = UIColor(red: 255/255, green: 185/255, blue: 70/255, alpha: 0.8)
    static let incorrectColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 0.8)
    
    // Opacity levels
    static let darkOpacity: CGFloat = 0.9
    static let normalOpacity: CGFloat = 0.8
    static let brightOpacity: CGFloat = 0.9
    static let glowIntensity: CGFloat = 0.8
    static let pulseIntensity: CGFloat = 0.5
}

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
        var movementPathNode: SCNNode?
        var rangeIndicatorNode: SCNNode?
        var warningLabel: UILabel?
        var warningView: UIVisualEffectView?
        
        init(headTracker: HeadTrackingManager) {
            self.headTracker = headTracker
            super.init()
            setupNodes()
        }
        
        private func setupNodes() {
            faceNode = SCNNode()
            setupMovementPath()
            setupRangeIndicator()
            setupArrow()
            setupFeedbackNode()
            setupAccuracyLabel()
            
            if let arrowNode = arrowNode,
               let feedbackNode = feedbackNode,
               let movementPathNode = movementPathNode,
               let rangeIndicatorNode = rangeIndicatorNode {
                faceNode?.addChildNode(arrowNode)
                faceNode?.addChildNode(feedbackNode)
                faceNode?.addChildNode(movementPathNode)
                faceNode?.addChildNode(rangeIndicatorNode)
            }
        }
        
        private func setupMovementPath() {
            // Create curved path for movement guide
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addCurve(
                to: CGPoint(x: 0, y: 0.3),
                controlPoint1: CGPoint(x: 0.1, y: 0.1),
                controlPoint2: CGPoint(x: -0.1, y: 0.2)
            )
            
            let shape = SCNShape(path: path, extrusionDepth: 0.001)
            let material = SCNMaterial()
            material.diffuse.contents = MedicalStyle.primaryBlue.withAlphaComponent(0.3)
            material.emission.contents = MedicalStyle.primaryBlue.withAlphaComponent(0.2)
            shape.materials = [material]
            
            movementPathNode = SCNNode(geometry: shape)
            movementPathNode?.opacity = 0.5
        }
        
        private func setupRangeIndicator() {
            // Create range boundaries
            let outerRing = SCNTorus(ringRadius: 0.3, pipeRadius: 0.002)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
            material.emission.contents = UIColor.white.withAlphaComponent(0.1)
            outerRing.materials = [material]
            
            rangeIndicatorNode = SCNNode(geometry: outerRing)
            rangeIndicatorNode?.position = SCNVector3(0, 0, -0.5)
        }
        
        private func setupArrow() {
            // Create a larger arrow cone
            let arrow = SCNCone(topRadius: 0, bottomRadius: 0.08, height: 0.16)  // Increased size
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemBlue
            material.emission.contents = UIColor.systemBlue
            material.lightingModel = .constant
            arrow.materials = [material]
            
            arrowNode = SCNNode(geometry: arrow)
            arrowNode?.position = SCNVector3(0, 0, -0.4)
            
            // Enhanced glow effect
            let glowNode = SCNNode(geometry: arrow.copy() as! SCNGeometry)
            glowNode.scale = SCNVector3(1.4, 1.4, 1.4)  // Increased glow size
            glowNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            glowNode.geometry?.firstMaterial?.emission.contents = UIColor.systemBlue.withAlphaComponent(0.8)
            glowNode.opacity = AdaptiveStyle.glowIntensity
            arrowNode?.addChildNode(glowNode)
            
            // Add a pulsing animation to make it more noticeable
            let pulseAction = SCNAction.sequence([
                SCNAction.scale(to: 1.1, duration: 0.5),
                SCNAction.scale(to: 1.0, duration: 0.5)
            ])
            arrowNode?.runAction(SCNAction.repeatForever(pulseAction))
        }
        
        private func setupFeedbackNode() {
            // Main feedback circle with double-layer design
            let circle = SCNPlane(width: 0.5, height: 0.5)
            
            // Create main material with higher opacity
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
            material.emission.contents = UIColor.white.withAlphaComponent(0.6)
            material.transparent.contents = UIColor.white.withAlphaComponent(0.3)
            material.isDoubleSided = true
            
            // Create border material with higher opacity
            let borderMaterial = SCNMaterial()
            borderMaterial.diffuse.contents = UIColor.white
            borderMaterial.emission.contents = UIColor.white
            
            // Create outer glow with higher opacity
            let glowPlane = SCNPlane(width: 0.52, height: 0.52)
            let glowMaterial = SCNMaterial()
            glowMaterial.diffuse.contents = UIColor.clear
            glowMaterial.emission.contents = UIColor.white.withAlphaComponent(0.6)
            
            let glowNode = SCNNode(geometry: glowPlane)
            glowNode.opacity = AdaptiveStyle.glowIntensity
            
            circle.materials = [material]
            
            feedbackNode = SCNNode(geometry: circle)
            feedbackNode?.position = SCNVector3(0, 0, -0.5)
            feedbackNode?.addChildNode(glowNode)
            
            // Adjust opacity based on screen brightness
            let screen = UIScreen.main
            feedbackNode?.opacity = screen.brightness > 0.5 ?
                AdaptiveStyle.brightOpacity : AdaptiveStyle.normalOpacity
        }
        
        private func setupAccuracyLabel() {
            accuracyLabel = UILabel()
            accuracyLabel?.textAlignment = .center
            accuracyLabel?.font = .systemFont(ofSize: 64, weight: .bold)
            accuracyLabel?.textColor = .white
            
            // Enhanced shadow for better visibility
            accuracyLabel?.layer.shadowColor = UIColor.black.cgColor
            accuracyLabel?.layer.shadowOffset = CGSize(width: 0, height: 2)
            accuracyLabel?.layer.shadowOpacity = 1.0
            accuracyLabel?.layer.shadowRadius = 8
        }
        
         func setupWarningMessage() {
            let blurEffect = UIBlurEffect(style: .dark)
            warningView = UIVisualEffectView(effect: blurEffect)
            warningView?.alpha = 0
            warningView?.layer.cornerRadius = 12
            warningView?.clipsToBounds = true
            
            warningLabel = UILabel()
            warningLabel?.text = "⚠️ Center your gaze"
            warningLabel?.textAlignment = .center
            warningLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            warningLabel?.textColor = MedicalStyle.warningText
            warningLabel?.numberOfLines = 0
            
            if let warningView = warningView, let warningLabel = warningLabel {
                warningView.contentView.addSubview(warningLabel)
                warningLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    warningLabel.centerXAnchor.constraint(equalTo: warningView.centerXAnchor),
                    warningLabel.centerYAnchor.constraint(equalTo: warningView.centerYAnchor),
                    warningLabel.leadingAnchor.constraint(equalTo: warningView.leadingAnchor, constant: 20),
                    warningLabel.trailingAnchor.constraint(equalTo: warningView.trailingAnchor, constant: -20)
                ])
            }
        }
        
        func showWarningMessage(_ show: Bool) {
            guard let warningView = warningView else { return }
            
            // Only animate if the state is changing
            if (show && warningView.alpha < 0.1) || (!show && warningView.alpha > 0.1) {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.beginFromCurrentState]) {
                    warningView.alpha = show ? 0.9 : 0
                }
            }
        }
        
        func updateFeedback(_ feedback: HeadTrackingManager.MovementFeedback, accuracy: Double) {
            guard let feedbackNode = feedbackNode else { return }
            
            let (baseColor, glowColor, intensity) = getAdaptiveFeedbackVisuals(feedback, accuracy: accuracy)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            
            // Update main feedback circle
            feedbackNode.geometry?.firstMaterial?.diffuse.contents = baseColor
            feedbackNode.geometry?.firstMaterial?.emission.contents = glowColor
            
            // Adjust opacity based on screen brightness
            let screen = UIScreen.main
            let baseOpacity = screen.brightness > 0.7 ?
                AdaptiveStyle.brightOpacity :
                (screen.brightness < 0.3 ? AdaptiveStyle.darkOpacity : AdaptiveStyle.normalOpacity)
            feedbackNode.opacity = CGFloat(Double(baseOpacity)) * intensity
            
            // Add pulse animation for correct movement
            if feedback == .correct {
                let pulseAction = SCNAction.sequence([
                    SCNAction.fadeOpacity(to: AdaptiveStyle.pulseIntensity, duration: 0.2),
                    SCNAction.fadeOpacity(to: 1.0, duration: 0.2)
                ])
                feedbackNode.runAction(pulseAction)
            }
            
            SCNTransaction.commit()
            
            // Update accuracy label with enhanced visibility
            DispatchQueue.main.async {
                self.accuracyLabel?.text = "\(Int(accuracy))%"
                self.accuracyLabel?.textColor = baseColor
                
                // Enhanced shadow for better visibility in all lighting
                self.accuracyLabel?.layer.shadowColor = UIColor.black.cgColor
                self.accuracyLabel?.layer.shadowOffset = CGSize(width: 0, height: 2)
                self.accuracyLabel?.layer.shadowOpacity = 0.8
                self.accuracyLabel?.layer.shadowRadius = 4
            }
        }
        
        private func getAdaptiveFeedbackVisuals(_ feedback: HeadTrackingManager.MovementFeedback, accuracy: Double) -> (UIColor, UIColor, CGFloat) {
            switch feedback {
            case .none:
                return (
                    UIColor.white.withAlphaComponent(0.3),
                    UIColor.white.withAlphaComponent(0.1),
                    0.5
                )
            case .correct:
                return (
                    AdaptiveStyle.correctColor,
                    AdaptiveStyle.correctColor.withAlphaComponent(0.5),
                    1.0
                )
            case .borderline:
                return (
                    AdaptiveStyle.warningColor,
                    AdaptiveStyle.warningColor.withAlphaComponent(0.5),
                    0.8
                )
            case .incorrect:
                return (
                    AdaptiveStyle.incorrectColor,
                    AdaptiveStyle.incorrectColor.withAlphaComponent(0.5),
                    0.8
                )
            }
        }
        
        func updateTargetPosition(_ direction: Direction) {
            guard let arrowNode = arrowNode else { return }
            
            let position = SCNVector3(0, 0, -0.5)
            let offset: Float = 0.2
            
            switch direction {
            case .up:
                arrowNode.position = SCNVector3(position.x, position.y + offset, position.z)
                arrowNode.eulerAngles = SCNVector3(Float.pi, 0, 0)
            case .down:
                arrowNode.position = SCNVector3(position.x, position.y - offset, position.z)
                arrowNode.eulerAngles = SCNVector3(0, 0, 0)
            case .left:
                arrowNode.position = SCNVector3(position.x - offset, position.y, position.z)
                arrowNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
            case .right:
                arrowNode.position = SCNVector3(position.x + offset, position.y, position.z)
                arrowNode.eulerAngles = SCNVector3(0, 0, -Float.pi / 2)
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            faceNode?.simdTransform = faceAnchor.transform
            
            // Get face orientation angles
            let eulerAngles = faceAnchor.transform.eulerAngles
            let pitch = abs(eulerAngles.x * 180 / .pi)  // Convert to degrees
            let yaw = abs(eulerAngles.y * 180 / .pi)    // Convert to degrees
            
            // Check if head is turned too far from center (more than 15 degrees in any direction)
            let isLookingAwayFromTarget = pitch > 15 || yaw > 15
            
            DispatchQueue.main.async {
                self.showWarningMessage(isLookingAwayFromTarget)
            }
            
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
                accuracyLabel.bottomAnchor.constraint(equalTo: arView.bottomAnchor, constant: -150),
                accuracyLabel.widthAnchor.constraint(equalToConstant: 200),
                accuracyLabel.heightAnchor.constraint(equalToConstant: 80)
            ])
        }
        
        context.coordinator.setupWarningMessage()
        if let warningView = context.coordinator.warningView {
            arView.addSubview(warningView)
            warningView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                warningView.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
                warningView.topAnchor.constraint(equalTo: arView.safeAreaLayoutGuide.topAnchor, constant: 20),
                warningView.widthAnchor.constraint(equalToConstant: 200),
                warningView.heightAnchor.constraint(equalToConstant: 40)
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
