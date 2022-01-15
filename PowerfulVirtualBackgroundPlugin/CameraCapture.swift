//
//  CameraCapture.swift
//  PowerfulVirtualBackgroundPlugin
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Cocoa
import AVFoundation

@objcMembers
class CameraCapture: NSObject {
    private let session = AVCaptureSession()
    let output = AVCaptureVideoDataOutput()

    override init() {
        session.sessionPreset = .high

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                    if session.canAddOutput(output) {
                        session.addOutput(output)
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    func startRunning() {
        session.startRunning()
    }

    func stopRunning() {
        session.stopRunning()
    }
}
