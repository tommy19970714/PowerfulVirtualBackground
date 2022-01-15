//
//  VirtualBackground.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Foundation
import VideoToolbox
import Vision
import CoreImage.CIFilterBuiltins
import Cocoa

class VirtualBackground: NSObject {
    private var model: MLModel!
    private var backgroundImage: NSImage!
    private var lastOutput: MLFeatureProvider?
    
    init(bundle: Bundle = .main) {
        super.init()
        let imageUrl = bundle.url(forResource: "background", withExtension: "jpeg")!
        backgroundImage = NSImage(contentsOf: imageUrl)
        let config = MLModelConfiguration()
        let modelURL = bundle.url(forResource: "rvm_mobilenetv3_1280x720_s0.375_fp16", withExtension: "mlmodelc")!
        self.model  = try! MLModel(contentsOf: modelURL, configuration: config)
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateBackgroundImage), name: NSNotification.selectBackgroundImage, object: nil)
        if let background = PasteboardUtil.current() {
            backgroundImage = background
        }
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    @objc func onUpdateBackgroundImage(sender: NSNotification) {
        if let background = PasteboardUtil.current() {
            backgroundImage = background
        }
    }
    
    @objc func timerUpdate() {
        if let background = PasteboardUtil.current() {
            backgroundImage = background
        }
    }
    
    func predict(imageBuffer: CVPixelBuffer) -> NSImage? {
        var featureDictionary: [String: Any] = [
            "src": imageBuffer
        ]
        if let lastOut = lastOutput {
            featureDictionary["r1i"] = lastOut.featureValue(for: "r1o")
            featureDictionary["r2i"] = lastOut.featureValue(for: "r2o")
            featureDictionary["r3i"] = lastOut.featureValue(for: "r3o")
            featureDictionary["r4i"] = lastOut.featureValue(for: "r4o")
        }
        let featureProvider = try! MLDictionaryFeatureProvider(dictionary: featureDictionary)
        let output = try! model.prediction(from: featureProvider)
        lastOutput = output
        for name in output.featureNames {
            if name == "pha", let featureValue = output.featureValue(for: name), let image = featureValue.imageBufferValue {
                let blend = CIFilter.blendWithMask()
                blend.backgroundImage = backgroundImage.ciImage
                blend.inputImage = CIImage(cvPixelBuffer: imageBuffer)
                blend.maskImage = CIImage(cvPixelBuffer: image)
                if let outputImage = blend.outputImage?.nsImage {
                    return outputImage
                }
            }
        }
        return nil
    }
}
