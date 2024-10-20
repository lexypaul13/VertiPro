//
//  CameraView.swift
//  VertiPro
//
//  Created by Alex Paul on 9/29/24.
//

import SwiftUI
import UIKit
import AVFoundation
struct CameraView: UIViewRepresentable {
    private let session = AVCaptureSession()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // Configure the capture session
        session.sessionPreset = .high
        
        // Select the front camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return view
        }
        
        // Add the camera input to the session
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("Error accessing front camera: \(error)")
            return view
        }
        
        // Set up the preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.frame = UIScreen.main.bounds
        
        view.layer.addSublayer(previewLayer)
        
        // Start the session
        DispatchQueue.main.async {
            session.startRunning()

        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
    
    func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        session.stopRunning()
    }
}
