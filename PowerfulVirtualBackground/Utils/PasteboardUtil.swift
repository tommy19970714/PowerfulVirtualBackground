//
//  PasteboardUtil.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Foundation
import Cocoa

extension NSPasteboard.Name {
    static let main = NSPasteboard.Name(Config.mainAppBundleIdentifier)
}

class PasteboardUtil {
    static func current() -> NSImage? {
        let pasteboard = NSPasteboard(name: .main)
        if let element = pasteboard.pasteboardItems?.last, let data = element.data(forType: .png), let image = NSImage(data: data) {
            return image
        }
        return nil
    }
    
    static func update(data: Data) {
        do {
            let pasteboard = NSPasteboard(name: .main)
            pasteboard.declareTypes([.png], owner: nil)
            pasteboard.setData(data, forType: .png)
        } catch {
            print("can't save data")
        }
    }
}
