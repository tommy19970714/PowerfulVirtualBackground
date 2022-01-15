//
//  VideoCapture.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import AVFoundation

public protocol VideoCaptureDelegate: class {
    func videoCapture(
        _ capture: VideoCapture,
        didCapture pixelBuffer: CVPixelBuffer?,
        with sampleTimingInfo: CMSampleTimingInfo
    )
}

extension VideoCaptureDelegate {
    func videoCapture(
        _ capture: VideoCapture,
        didDrop pixelBuffer: CVPixelBuffer?,
        with sampleTimingInfo: CMSampleTimingInfo
    ) {}
}

public class VideoCapture: NSObject {
    public weak var delegate: VideoCaptureDelegate?
    
    public var desiredFPS = 30
    
    private lazy var captureSession = AVCaptureSession()
    private lazy var videoOutput = AVCaptureVideoDataOutput()
    private lazy var queue = DispatchQueue.main
    
    var lastPresentationTimestamp = CMTime()
    
    public func setUp() {
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = .hd1280x720
        
        // Set up our capture session and leave no second chances
        let captureDevice = AVCaptureDevice.default(for: .video)!
        let videoInput = try! AVCaptureDeviceInput(device: captureDevice)
        guard captureSession.canAddInput(videoInput) else {fatalError()}
        captureSession.addInput(videoInput)
        
        // Keep in mind that the OS has to convert the camera stream
        // which is naturally recorded in YUV color space, so choosing
        // any output format (such as BGRA) impacts the performance
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        ]
        
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        guard captureSession.canAddOutput(videoOutput) else {fatalError()}
        captureSession.addOutput(videoOutput)
        
        captureSession.commitConfiguration()
    }
    
    public func start() {
        guard !captureSession.isRunning else {return}
        captureSession.startRunning()
    }
    
    public func stop() {
        guard captureSession.isRunning else {return}
        captureSession.stopRunning()
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        var sampleTimingInfo = CMSampleTimingInfo()
        guard CMSampleBufferGetSampleTimingInfo(
            sampleBuffer,
            at: 0,
            timingInfoOut: &sampleTimingInfo
        ) == noErr else {return}
        
        let elapsedPresentationTime = sampleTimingInfo.presentationTimeStamp - lastPresentationTimestamp
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // Only dispatch the event, if the elapsed time is greater than a single frame
        if elapsedPresentationTime >= CMTimeMake(value: 1, timescale: Int32(desiredFPS)) {
            lastPresentationTimestamp = sampleTimingInfo.presentationTimeStamp
            
            delegate?.videoCapture(self, didCapture: pixelBuffer, with: sampleTimingInfo)
        }
    }
}
