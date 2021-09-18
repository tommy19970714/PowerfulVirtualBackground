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
}

extension CIImage {
    public var nsImage: NSImage {
        let rep = NSCIImageRep(ciImage: self)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}
