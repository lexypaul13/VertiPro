import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let headTracker: HeadTrackingManager
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var arView: ARSCNView?
        let headTracker: HeadTrackingManager
        
        init(headTracker: HeadTrackingManager) {
            self.headTracker = headTracker
            super.init()
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
