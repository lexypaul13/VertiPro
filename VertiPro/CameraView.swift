import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        // Setup camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high // Add this line
        
        // Check and request camera permissions
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera(view, captureSession)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera(view, captureSession)
                    }
                }
            }
        default:
            print("Camera access denied")
        }
        
        return view
    }
    
    private func setupCamera(_ view: UIView, _ captureSession: AVCaptureSession) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .front) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        
        DispatchQueue.main.async {
            view.layer.addSublayer(previewLayer)
            captureSession.startRunning()
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
