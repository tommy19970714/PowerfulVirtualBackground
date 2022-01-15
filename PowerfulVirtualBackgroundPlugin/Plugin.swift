//
//  Plugin.swift
//  PowerfulVirtualBackgroundPlugin
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Foundation

class Plugin: Object {
    var objectID: CMIOObjectID = 0
    let name = "PowerfulVirtualBackground"

    lazy var properties: [Int : Property] = [
        kCMIOObjectPropertyName: Property(name),
    ]
}
