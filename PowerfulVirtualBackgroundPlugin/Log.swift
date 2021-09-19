//
//  Log.swift
//  PowerfulVirtualBackgroundPlugin
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Foundation

func log(_ message: Any = "", function: String = #function) {
    NSLog("PowerfulVirtualBackground: \(function): \(message)")
}
