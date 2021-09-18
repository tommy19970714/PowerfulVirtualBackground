//
//  ContentView.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/18.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            InputImageView()
            Spacer()
            .frame(maxHeight: 20)
        }
    }
}

struct InputImageView: View {
    
    var body: some View {
        ZStack {
            cameraPreview().animation(.spring())
        }
        .frame(height: 320)
        .cornerRadius(8)
    }
    
    func cameraPreview() -> AnyView {
        if Config.useVirtualCamera, let cameraDevice = AVCaptureDevice.init(uniqueID: "Powerfull Virtual Background Device") {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
