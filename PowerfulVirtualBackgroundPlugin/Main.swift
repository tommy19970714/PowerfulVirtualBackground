//
//  Main.swift
//  PowerfulVirtualBackgroundPlugin
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Foundation
import CoreMediaIO

@_cdecl("PowerfulVirtualBackground")
public func simpleDALPluginMain(allocator: CFAllocator, requestedTypeUUID: CFUUID) -> CMIOHardwarePlugInRef {
    NSLog("PowerfulVirtualBackground")
    return pluginRef
}
