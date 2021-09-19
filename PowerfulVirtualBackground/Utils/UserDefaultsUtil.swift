//
//  UserDefaultsUtil.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Foundation
import Cocoa

class UserDefaultsUtil {
    static let userDefaults = UserDefaults.standard
    
    enum key: String {
        case backgroundImage = "backgroundImage"
    }
    
    static var backgroundImage: NSImage? {
        get {
            if let data = userDefaults.data(forKey: key.backgroundImage.rawValue), let image = NSImage(data: data) {
                return image
            }
            return nil
        }
        set {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
                userDefaults.set(data, forKey: key.backgroundImage.rawValue)
                userDefaults.synchronize()
            } catch {
                print("can't save data")
            }
        }
    }
    
    static var backgroundImageData: Data? {
        get {
            return userDefaults.data(forKey: key.backgroundImage.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: key.backgroundImage.rawValue)
            userDefaults.synchronize()
        }
    }
}
