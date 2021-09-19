//
//  Device.swift
//  PowerfulVirtualBackgroundPlugin
//
//  Created by Toshiki Tomihira on 2021/09/19.
//

import Foundation
import IOKit

class Device: Object {
    var objectID: CMIOObjectID = 0
    var streamID: CMIOStreamID = 0
    let name = "PowerfulVirtualBackground"
    let manufacturer = "Toshiki Tomihira"
    let deviceUID = "PowerfulVirtualBackground Device"
    let modelUID = "PowerfulVirtualBackground Model"
    var excludeNonDALAccess: Bool = false
    var deviceMaster: Int32 = 0
    var elementCategoryName = "Virtual Camera"
    var elementNumberName = "Virtual Camera"
    var pluginID: CMIOObjectID = 0

    lazy var properties: [Int : Property] = [
        kCMIOObjectPropertyName: Property(name),
        kCMIOObjectPropertyManufacturer: Property(manufacturer),
        kCMIOObjectPropertyElementCategoryName: Property(elementCategoryName),
        kCMIOObjectPropertyElementNumberName:Property(elementNumberName),
        kCMIODevicePropertyPlugIn: Property(pluginID),
        
        kCMIODevicePropertyDeviceUID: Property(deviceUID),
        kCMIODevicePropertyModelUID: Property(modelUID),
        kCMIODevicePropertyTransportType: Property(UInt32(kIOAudioDeviceTransportTypeBuiltIn)),
        kCMIODevicePropertyDeviceIsAlive: Property(UInt32(1)),
        kCMIODevicePropertyDeviceHasChanged: Property(UInt32(0)),
        kCMIODevicePropertyDeviceIsRunning: Property(UInt32(1)),
        kCMIODevicePropertyDeviceIsRunningSomewhere: Property(UInt32(1)),
        kCMIODevicePropertyDeviceCanBeDefaultDevice: Property(UInt32(1)),
        kCMIODevicePropertyCanProcessAVCCommand: Property(UInt32(0)),
        kCMIODevicePropertyCanProcessRS422Command: Property(UInt32(0)),
        kCMIODevicePropertyLatency: Property(UInt32(0)),
        kCMIODevicePropertyHogMode: Property(Int32(-1)),
        kCMIODevicePropertyStreams: Property { [unowned self] in self.streamID },
        kCMIODevicePropertyExcludeNonDALAccess: Property(
            getter: { [unowned self] () -> UInt32 in self.excludeNonDALAccess ? 1 : 0 },
            setter: { [unowned self] (value: UInt32) -> Void in self.excludeNonDALAccess = value != 0  }
        ),
        kCMIODevicePropertyDeviceMaster: Property(
            getter: { [unowned self] () -> Int32 in self.deviceMaster },
            setter: { [unowned self] (value: Int32) -> Void in self.deviceMaster = value  }
        ),
    ]
}
