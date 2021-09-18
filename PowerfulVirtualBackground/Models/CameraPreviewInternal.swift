//
//  CameraPreviewInternal.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/18.
//

import Foundation
import AVFoundation
import Cocoa
import VideoToolbox
import Vision
import CoreImage.CIFilterBuiltins

extension NSNotification {
    static let selectBackgroundImage = NSNotification.Name.init("selectBackgroundImage")
}

class CameraPreviewInternal: NSView, AVCaptureAudioDataOutputSampleBufferDelegate {
    var captureDevice: AVCaptureDevice?
    private var captureSession: AVCaptureSession
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoInput: AVCaptureInput?
    private var videoOutput = AVCaptureVideoDataOutput()
    private var videoConnection: AVCaptureConnection?
    private var imageView: NSImageView!
    let videoDataOutputQueue = DispatchQueue(label: "com.toshiki.PowerfullVirtualBackground.videoDataOutputQueue")
    private var executing = false
    private var vartualBackground = VirtualBackground()

    init(frame frameRect: NSRect, device: AVCaptureDevice?) {
        captureDevice = device
        captureSession = AVCaptureSession()

        super.init(frame: frameRect)

        configureDevice(device)
        setupPreviewLayer(captureSession)
        captureSession.startRunning()
    }

    private func setupPreviewLayer(_ captureSession: AVCaptureSession) {
        if Config.useVirtualCamera {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = CGRect(x: 0, y: 0, width: 400, height: 225)
            previewLayer.videoGravity = .resizeAspect
        } else {
            imageView = NSImageView(frame: CGRect(x: 0, y: 0, width: 400, height: 225))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        if Config.useVirtualCamera {
            previewLayer.frame = bounds
            layer?.addSublayer(previewLayer)
        } else {
            imageView.frame = bounds
            addSubview(imageView)
        }
    }

    func stopRunning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func startRunning() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func updateCamera(_ cam: AVCaptureDevice?) {
        if captureDevice != cam {
            captureSession.stopRunning()
            configureDevice(cam)
            captureSession.startRunning()
        }
    }

    private func configureDevice(_ aDevice: AVCaptureDevice?) {
        guard let device = aDevice else {
            captureDevice = aDevice
            return
        }
        
        // Check if the output has already been added.
        if captureSession.outputs.contains(videoOutput) {
            captureSession.removeOutput(videoOutput)
        }
        
        if let highestResolution = self.highestResolution420Format(for: device) {
            try? device.lockForConfiguration()
            device.activeFormat = highestResolution.format
            device.unlockForConfiguration()
        }

        if let input = videoInput {
            captureSession.removeInput(input)
        }

        do {
            videoInput = try AVCaptureDeviceInput(device: device)
        } catch {
            return
        }

        if let input = videoInput,
            captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            return
        }
        captureDevice = device
        
        if !Config.useVirtualCamera {
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            videoOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            
            videoOutput.connection(with: .video)?.isEnabled = true
            
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
        }
    }
    
    /// - Tag: ConfigureDeviceResolution
    fileprivate func highestResolution420Format(for device: AVCaptureDevice) -> (format: AVCaptureDevice.Format, resolution: CGSize)? {
        var highestResolutionFormat: AVCaptureDevice.Format? = nil
        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)
        
        for format in device.formats {
            let deviceFormat = format as AVCaptureDevice.Format
            
            let deviceFormatDescription = deviceFormat.formatDescription
            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange {
                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription)
                if (highestResolutionFormat == nil) || (candidateDimensions.width > highestResolutionDimensions.width) {
                    highestResolutionFormat = deviceFormat
                    highestResolutionDimensions = candidateDimensions
                }
            }
        }
        
        if highestResolutionFormat != nil {
            let resolution = CGSize(width: CGFloat(highestResolutionDimensions.width), height: CGFloat(highestResolutionDimensions.height))
            return (highestResolutionFormat!, resolution)
        }
        return nil
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraPreviewInternal: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if executing {
            return
        }
        executing = true
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let output = vartualBackground.predict(imageBuffer: imageBuffer)
        DispatchQueue.main.async {
            self.imageView.image = output
        }
        executing = false
    }
}
