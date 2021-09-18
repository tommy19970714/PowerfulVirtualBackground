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
    private var backgroundImage = NSImage(named: "background")!
    private var lastOutput: MLFeatureProvider?
    
    override init() {
        super.init()
        let config = MLModelConfiguration()
        self.model = try! rvm_mobilenetv3_1280x720_s0_375_fp16(configuration: config).model
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdateBackgroundImage), name: NSNotification.selectBackgroundImage, object: nil)
        backgroundImage = UserDefaultsUtil.backgroundImage
    }
    
    @objc func onUpdateBackgroundImage(sender: NSNotification) {
        backgroundImage = UserDefaultsUtil.backgroundImage
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
