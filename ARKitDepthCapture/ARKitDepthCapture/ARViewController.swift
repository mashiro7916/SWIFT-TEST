//
//  ARViewController.swift
//  ARKitDepthCapture
//
//  ARKit View Controller - Capture RGB and LiDAR Depth Maps
//

import UIKit
import ARKit
import AVFoundation
import Photos

class ARViewController: UIViewController {
    
    // MARK: - Properties
    private var arView: ARSCNView!
    private var captureButton: UIButton!
    private var statusLabel: UILabel!
    
    private var isCapturing = false
    private var frameCount = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupARSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseARSession()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        // AR View
        arView = ARSCNView(frame: view.bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.delegate = self
        view.addSubview(arView)
        
        // Status Label
        statusLabel = UILabel()
        statusLabel.text = "Ready"
        statusLabel.textColor = .white
        statusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statusLabel.layer.cornerRadius = 8
        statusLabel.clipsToBounds = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Capture Button
        captureButton = UIButton(type: .system)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.backgroundColor = .systemBlue
        captureButton.layer.cornerRadius = 30
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusLabel.heightAnchor.constraint(equalToConstant: 44),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - AR Session Setup
    private func setupARSession() {
        arView.session.delegate = self
    }
    
    private func startARSession() {
        // Check LiDAR support
        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) else {
            showAlert(title: "Not Supported", message: "This device does not support LiDAR depth sensing")
            updateStatus("LiDAR not supported")
            return
        }
        
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable scene reconstruction to use LiDAR
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            configuration.sceneReconstruction = .meshWithClassification
        }
        
        // Enable depth map
        configuration.frameSemantics.insert(.sceneDepth)
        configuration.frameSemantics.insert(.smoothedSceneDepth)
        
        arView.session.run(configuration)
        updateStatus("AR Session Started")
    }
    
    private func pauseARSession() {
        arView.session.pause()
    }
    
    // MARK: - Actions
    @objc private func captureButtonTapped() {
        guard !isCapturing else { return }
        captureFrame()
    }
    
    // MARK: - Capture Methods
    private func captureFrame() {
        guard let frame = arView.session.currentFrame else {
            updateStatus("Failed to get current frame")
            return
        }
        
        isCapturing = true
        updateStatus("Capturing...")
        captureButton.isEnabled = false
        
        // Capture RGB image
        let pixelBuffer = frame.capturedImage
        let rgbImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Capture depth map
        var depthMap: CVPixelBuffer?
        if let depthData = frame.sceneDepth ?? frame.smoothedSceneDepth {
            depthMap = depthData.depthMap
        }
        
        // Convert and save images
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Save RGB image
            if let rgbCGImage = self.convertCIImageToCGImage(rgbImage) {
                self.saveImage(rgbCGImage, type: .rgb)
            }
            
            // Save depth map
            if let depthMap = depthMap {
                self.saveDepthMap(depthMap)
            }
            
            DispatchQueue.main.async {
                self.isCapturing = false
                self.captureButton.isEnabled = true
                self.frameCount += 1
                self.updateStatus("Saved image #\(self.frameCount)")
            }
        }
    }
    
    // MARK: - Image Conversion
    private func convertCIImageToCGImage(_ ciImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        
        // Adjust image orientation (ARKit images are landscape)
        let transform = CGAffineTransform(rotationAngle: .pi / 2)
        let rotatedImage = ciImage.transformed(by: transform)
        
        return context.createCGImage(rotatedImage, from: rotatedImage.extent)
    }
    
    // MARK: - Save Methods
    private enum ImageType {
        case rgb
        case depth
    }
    
    private func saveImage(_ cgImage: CGImage, type: ImageType) {
        let image = UIImage(cgImage: cgImage)
        
        // Get file path
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let prefix = type == .rgb ? "RGB" : "Depth"
        let filename = "\(prefix)_\(timestamp).png"
        let fileURL = documentsPath.appendingPathComponent(filename)
        
        // Save as PNG to Documents directory (accessible via Files app)
        if let imageData = image.pngData() {
            do {
                try imageData.write(to: fileURL)
                print("Saved to Documents: \(filename)")
            } catch {
                print("Save to Documents failed: \(error.localizedDescription)")
            }
        }
        
        // Also save to Photo Library (accessible via Photos app)
        saveToPhotoLibrary(image)
    }
    
    private func saveToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized || status == .limited else {
                print("Photo library access denied")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                if success {
                    print("Saved to Photo Library")
                } else if let error = error {
                    print("Save to Photo Library failed: \(error.localizedDescription)")
                }
            })
        }
    }
    
    private func saveDepthMap(_ depthMap: CVPixelBuffer) {
        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        
        CVPixelBufferLockBaseAddress(depthMap, CVPixelBufferLockFlags(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(depthMap, CVPixelBufferLockFlags(rawValue: 0)) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap) else {
            return
        }
        
        // Depth data is in Float32 format
        let floatBuffer = baseAddress.assumingMemoryBound(to: Float32.self)
        
        // Create grayscale image buffer
        let bytesPerPixel = 1
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return
        }
        
        guard let pixelData = context.data else {
            return
        }
        
        let grayBuffer = pixelData.assumingMemoryBound(to: UInt8.self)
        
        // Find min and max depth values
        var minDepth: Float = Float.greatestFiniteMagnitude
        var maxDepth: Float = 0.0
        
        for i in 0..<(width * height) {
            let depth = floatBuffer[i]
            if depth > 0 && depth.isFinite {
                minDepth = min(minDepth, depth)
                maxDepth = max(maxDepth, depth)
            }
        }
        
        let depthRange = maxDepth - minDepth
        
        // Convert depth values to grayscale
        for i in 0..<(width * height) {
            let depth = floatBuffer[i]
            
            if depth > 0 && depth.isFinite && depthRange > 0 {
                // Normalize depth value (0.0 - 1.0)
                let normalizedDepth = (depth - minDepth) / depthRange
                grayBuffer[i] = UInt8(normalizedDepth * 255)
            } else {
                // Invalid depth values shown as black
                grayBuffer[i] = 0
            }
        }
        
        // Save depth map as image
        if let depthCGImage = context.makeImage() {
            saveImage(depthCGImage, type: .depth)
        }
    }
    
    // MARK: - Helper Methods
    private func updateStatus(_ text: String) {
        DispatchQueue.main.async {
            self.statusLabel.text = text
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - ARSessionDelegate
extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        updateStatus("AR Session Error: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        updateStatus("AR Session Interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        updateStatus("AR Session Resumed")
        startARSession()
    }
}

// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
    // Optional: Add AR view delegate methods
}

