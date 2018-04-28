//
//  DeviceSupportFileEntry.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 27.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

public final class DeviceSupportFileEntry: XcodeFileEntry {
    public let device: String?
    public let version: Version
    public let build: String
    
    public init(device: String?, version: Version, build: String, icon: Icon? = nil, selected: Bool) {
        self.device = device
        self.version = version
        self.build = build
        
        super.init(label: "\(self.version) \(self.build)", icon: icon, selected: selected)
    }
}
