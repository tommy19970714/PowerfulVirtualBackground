//
//  Config.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/18.
//

import Foundation
import Cocoa

class Config {

    static var useVirtualCamera: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    static let mainAppBundleIdentifier = "com.toshiki.PowerfulVirtualBackground"
    
    static let settingFileName = "Settings.json"
    
    static let groupId = "J6246ZXP2D" + mainAppBundleIdentifier
}
