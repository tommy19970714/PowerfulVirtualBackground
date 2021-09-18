//
//  NSImage+Extension.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/18.
//

import Foundation
import Cocoa

extension NSImage {
    public var ciImage: CIImage? {
        guard let imageData = self.tiffRepresentation else { return nil }
        return CIImage(data: imageData)
    }
    
    func resize(width: Int, height: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(width), CGFloat(height))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, size.width, size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
           let width = self.size.width
           let height = self.size.height
           let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
           var pixelBuffer: CVPixelBuffer?
           let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                            Int(width),
                                            Int(height),
                                            kCVPixelFormatType_32ARGB,
                                            attrs,
                                            &pixelBuffer)
           
           guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
               return nil
           }
           
           CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
           let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
           
           let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
           guard let context = CGContext(data: pixelData,
                                         width: Int(width),
                                         height: Int(height),
                                         bitsPerComponent: 8,
                                         bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                         space: rgbColorSpace,
                                         bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {return nil}
           
           let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
           NSGraphicsContext.saveGraphicsState()
           NSGraphicsContext.current = graphicsContext
           draw(in: CGRect(x: 0, y: 0, width: width, height: height))
           NSGraphicsContext.restoreGraphicsState()
           
           CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
           
           return resultPixelBuffer
       }
}

extension CIImage {
    public var nsImage: NSImage {
        let rep = NSCIImageRep(ciImage: self)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}
