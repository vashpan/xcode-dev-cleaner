//
//  DeviceSupportFileEntry.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 27.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//
//  DevCleaner is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  DevCleaner is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with DevCleaner.  If not, see <http://www.gnu.org/licenses/>.

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
    public let date: Date
    public let architecture: String?
    
    // MARK: Initialization
    public init(device: String?, osType: OSType, version: Version, build: String, date: Date, arch: String?, selected: Bool) {
        self.device = device
        self.osType = osType
        self.version = version
        self.build = build
        self.date = date
        self.architecture = arch
        
        let label = "\(self.osType.description) \(self.version) \(self.build)"
        let tooltip = label + " " + DateFormatter.localizedString(from: self.date, dateStyle: .medium, timeStyle: .none)
        
        super.init(label: label, tooltipText: tooltip, icon: DeviceSupportFileEntry.icon(for: osType, version: version), tooltip: true, selected: selected)
    }
    
    // MARK: Helpers
    private static func icon(for os: OSType, version: Version) -> Icon {
        var result: Icon
        
        switch os {
            case .iOS:
                if version.major >= 2 && version.major <= 14 {
                    result = .image(name: "OS/iOS/\(version.major)")
                } else {
                    result = .image(name: "OS/iOS/Generic")
                }
            
            case .watchOS:
                if version.major >= 2 && version.major <= 7 {
                    result = .image(name: "OS/watchOS/\(version.major)")
                } else {
                    result = .image(name: "OS/watchOS/Generic")
                }
            
            case .tvOS:
                if version.major >= 9 && version.major <= 14 {
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
