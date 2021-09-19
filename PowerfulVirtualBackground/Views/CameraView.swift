//
//  CameraView.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraView: View {
    var body: some View {
        ZStack {
            cameraPreview().animation(.spring())
        }
        .frame(height: 320)
        .cornerRadius(8)
    }
    
    func cameraPreview() -> AnyView {
        if Config.useVirtualCamera, let cameraDevice = AVCaptureDevice.init(uniqueID: "PowerfulVirtualBackground Device") {
            return AnyView(CameraPreview(captureDevice: cameraDevice)
            .frame(width: 640, height: 360))
        }
        if !Config.useVirtualCamera, let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
            return AnyView(CameraPreview(captureDevice: cameraDevice)
            .frame(width: 640, height: 360))
        }
        return AnyView(Text("No camera")
        .frame(width: 320)
        .background(Color.black.opacity(0.5)))
    }
}
