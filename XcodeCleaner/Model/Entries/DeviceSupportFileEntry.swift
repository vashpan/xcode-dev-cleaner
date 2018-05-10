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
        
        public var description: String {
            switch self {
                case .iOS:
                    return "iOS"
                case .watchOS:
                    return "watchOS"
                case .tvOS:
                    return "tvOS"
                case .other:
                    return ""
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
        
        super.init(label: "\(self.osType.description) \(self.version) \(self.build)", icon: DeviceSupportFileEntry.icon(for: osType, version: version), selected: selected)
    }
    
    // MARK: Helpers
    private static func icon(for os: OSType, version: Version) -> Icon {
        var result: Icon
        
        switch os {
            case .iOS:
                if version.major >= 2 && version.major <= 11 {
                    result = .image(name: "OS/iOS/\(version.major)")
                } else {
                    result = .image(name: "OS/iOS/Generic")
                }
            
            case .watchOS:
                if version.major >= 2 && version.major <= 4 {
                    result = .image(name: "OS/watchOS/\(version.major)")
                } else {
                    result = .image(name: "OS/watchOS/Generic")
                }
            
            case .tvOS:
                if version.major >= 9 && version.major <= 11 {
                    result = .image(name: "OS/tvOS/\(version.major)")
                } else {
                    result = .image(name: "OS/tvOS/Generic")
                }
            
            default:
                result = .image(name: "OS/iOS/Generic")
        }
        
        return result
    }
}
