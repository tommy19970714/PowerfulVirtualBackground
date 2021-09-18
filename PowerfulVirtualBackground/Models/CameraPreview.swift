//
//  CameraPreview.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/18.
//

import SwiftUI
import AVFoundation

struct CameraPreview: NSViewRepresentable {
    var captureDevice: AVCaptureDevice?

    func makeNSView(context: Context) -> CameraPreviewInternal {
        return CameraPreviewInternal(frame: .zero, device: captureDevice)
    }

    func updateNSView(_ nsView: CameraPreviewInternal, context: NSViewRepresentableContext<CameraPreview>) {
        nsView.updateCamera(captureDevice)
    }

    static func dismantleNSView(_ nsView: CameraPreviewInternal, coordinator: ()) {
        nsView.stopRunning()
    }
}
