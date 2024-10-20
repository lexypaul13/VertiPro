import SwiftUI
import ARKit
import SceneKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var currentTargetDirection: Direction {
          didSet {
              print("ARViewContainer: currentTargetDirection changed to \(currentTargetDirection.rawValue)")
          }
      }
    @Binding var targetHit: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        context.coordinator.sceneView = arView

        // Enable default lighting
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true

        // Check if face tracking is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            print("ARFaceTracking is not supported on this device.")
            return arView
        }

        // Set up the AR configuration
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)

        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        print("ARViewContainer: currentTargetDirection changed to \(currentTargetDirection.rawValue)")

        context.coordinator.updateTargets()
    }


    func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        uiView.session.pause()
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer
        var sceneView: ARSCNView?
        var arrowNodes: [Direction: SCNNode] = [:]

        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
            createArrowNodes()
        }

        func createArrowNodes() {
            for direction in Direction.allCases {
                if let arrowNode = createArrowNode(for: direction) {
                    arrowNodes[direction] = arrowNode
                    print("Created arrow node for direction: \(direction.rawValue)")
                } else {
                    print("Failed to create arrow node for direction: \(direction.rawValue)")
                }
            }
        }


        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARFaceAnchor else { return }
            print("renderer: didAdd node called")
            for arrowNode in arrowNodes.values {
                node.addChildNode(arrowNode)
                print("Added arrow node for direction: \(arrowNode.name ?? "unknown")")
            }
        }



        func createArrowNode(for direction: Direction) -> SCNNode? {
            // Draw the arrow image for the given direction
            guard let arrowImage = drawArrowImage(direction: direction) else {
                print("Error: Unable to draw arrow image for direction \(direction.rawValue)")
                return nil
            }

            // Create a plane to display the arrow image
            let plane = SCNPlane(width: 0.1, height: 0.1)
            let material = SCNMaterial()
            material.diffuse.contents = arrowImage
            material.isDoubleSided = true
            plane.firstMaterial = material

            let arrowNode = SCNNode(geometry: plane)

            // Position the arrow relative to the face
            var position = SCNVector3(0, 0, -0.3) // Base position in front of the face
            let offset: Float = 0.15 // Adjust as needed

            switch direction {
            case .left:
                position.x -= offset
            case .right:
                position.x += offset
            case .up:
                position.y += offset
            case .down:
                position.y -= offset
            }

            arrowNode.position = position

            // Add a billboard constraint to face the camera
            let billboardConstraint = SCNBillboardConstraint()
            billboardConstraint.freeAxes = .all
            arrowNode.constraints = [billboardConstraint]

            arrowNode.name = direction.rawValue
            arrowNode.isHidden = true // Initially hidden

            return arrowNode
        }


        func drawArrowImage(direction: Direction) -> UIImage? {
            let size = CGSize(width: 200, height: 200)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            guard let context = UIGraphicsGetCurrentContext() else {
                UIGraphicsEndImageContext()
                return nil
            }

            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(20)
            context.setLineCap(.round)
            context.setLineJoin(.round)

            let path = UIBezierPath()

            // Draw an arrow pointing in the specified direction
            switch direction {
            case .up:
                path.move(to: CGPoint(x: size.width / 2, y: size.height))
                path.addLine(to: CGPoint(x: size.width / 2, y: 0))
                path.move(to: CGPoint(x: size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: size.width / 2 - 50, y: 50))
                path.move(to: CGPoint(x: size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: size.width / 2 + 50, y: 50))
            case .down:
                path.move(to: CGPoint(x: size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: size.width / 2, y: size.height))
                path.move(to: CGPoint(x: size.width / 2, y: size.height))
                path.addLine(to: CGPoint(x: size.width / 2 - 50, y: size.height - 50))
                path.move(to: CGPoint(x: size.width / 2, y: size.height))
                path.addLine(to: CGPoint(x: size.width / 2 + 50, y: size.height - 50))
            case .left:
                path.move(to: CGPoint(x: size.width, y: size.height / 2))
                path.addLine(to: CGPoint(x: 0, y: size.height / 2))
                path.move(to: CGPoint(x: 0, y: size.height / 2))
                path.addLine(to: CGPoint(x: 50, y: size.height / 2 - 50))
                path.move(to: CGPoint(x: 0, y: size.height / 2))
                path.addLine(to: CGPoint(x: 50, y: size.height / 2 + 50))
            case .right:
                path.move(to: CGPoint(x: 0, y: size.height / 2))
                path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
                path.move(to: CGPoint(x: size.width, y: size.height / 2))
                path.addLine(to: CGPoint(x: size.width - 50, y: size.height / 2 - 50))
                path.move(to: CGPoint(x: size.width, y: size.height / 2))
                path.addLine(to: CGPoint(x: size.width - 50, y: size.height / 2 + 50))
            }

            path.stroke()

            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }


        func updateTargets() {
            for (direction, node) in arrowNodes {
                node.isHidden = direction != parent.currentTargetDirection
                print("Arrow \(direction.rawValue) isHidden: \(node.isHidden)")
            }
        }








        func printNodeHierarchy(_ node: SCNNode, level: Int = 0) {
            let indent = String(repeating: "  ", count: level)
            print("\(indent)\(node.name ?? "unnamed") - Position: \(node.position), Hidden: \(node.isHidden)")
            for childNode in node.childNodes {
                printNodeHierarchy(childNode, level: level + 1)
            }
        }
    }
}
