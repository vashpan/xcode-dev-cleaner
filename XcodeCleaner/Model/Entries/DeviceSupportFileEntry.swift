//
//  DeviceSupportFileEntry.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 27.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

public final class DeviceSupportFileEntry: XcodeFileEntry {
    // MARK: Types
    public enum OSType {
        case iOS, watchOS, tvOS, other
        
        public init(label: String) {
            switch label {
                case "iOS":
                    self = .iOS
                case "watchOS":
                    self = .watchOS
                case "tvOS":
                    self = .tvOS
                default:
                    self = .other
            }
        }
    }
    
    // MARK: Properties
    public let device: String?
    public let osType: OSType
    public let version: Version
    public let build: String
    
    // MARK: Initialization
    public init(device: String?, osType: OSType, version: Version, build: String, selected: Bool) {
        self.device = device
        self.osType = osType
        self.version = version
        self.build = build
        
        super.init(label: "\(self.version) \(self.build)", icon: nil, selected: selected)
    }
}
