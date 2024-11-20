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
        case iOS, watchOS, tvOS, macOS, visionOS, other
        
        public init(label: String) {
            switch label {
                case "iOS":
                    self = .iOS
                case "watchOS":
                    self = .watchOS
                case "tvOS":
                    self = .tvOS
                case "macOS":
                    self = .macOS
                case "visionOS":
                    self = .visionOS
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
                case .macOS:
                    return "macOS"
                case .visionOS:
                    return "visionOS"
                case .other:
                    return ""
            }
        }
    }
    
    // MARK: Properties
    public let device: String?
    public let osType: OSType
    public let version: Version
    public let build: AppleBuild?
    public let date: Date
    public let architecture: String?
    
    // MARK: Initialization
    public init(device: String?, osType: OSType, version: Version, build: AppleBuild?, date: Date, arch: String?, selected: Bool) {
        self.device = device
        self.osType = osType
        self.version = version
        self.build = build
        self.date = date
        self.architecture = arch
        
        let label = Self.label(for: osType, device: device, version: version, build: build)
        let icon = Self.icon(for: osType, version: version)
        let tooltip = label + " " + DateFormatter.localizedString(from: self.date, dateStyle: .medium, timeStyle: .none)
        
        super.init(label: label, tooltipText: tooltip, icon: icon, tooltip: true, selected: selected)
    }
    
    // MARK: Helpers
    private static func label(for os: OSType, device: String?, version: Version, build: AppleBuild?) -> String {
        let appleBuild = build ?? .empty
        
        var result = "\(os.description) \(version) \(appleBuild)"
        if let device {
            result = result + " (\(Self.modelName(from: device)))"
        }
        
        return result
    }
    
    private static func icon(for os: OSType, version: Version) -> Icon {
        var result: Icon
        
        switch os {
            case .iOS:
                if version.major >= 2 && version.major <= 18 {
                    result = .image(name: "OS/iOS/\(version.major)")
                } else {
                    result = .image(name: "OS/iOS/Generic")
                }
            
            case .watchOS:
                if version.major >= 2 && version.major <= 11 {
                    result = .image(name: "OS/watchOS/\(version.major)")
                } else {
                    result = .image(name: "OS/watchOS/Generic")
                }
            
            case .tvOS:
                if version.major >= 9 && version.major <= 18 {
                    result = .image(name: "OS/tvOS/\(version.major)")
                } else {
                    result = .image(name: "OS/tvOS/Generic")
                }
                
            case .macOS:
                if version.major >= 12 && version.major <= 15 {
                    result = .image(name: "OS/macOS/\(version.major)")
                } else {
                    result = .image(name: "OS/macOS/Generic")
                }
                
            case .visionOS:
                if version.major >= 2 && version.major <= 2 {
                    result = .image(name: "OS/visionOS/\(version.major)")
                } else {
                    result = .image(name: "OS/visionOS/Generic")
                }
                
            default:
                result = .image(name: "OS/iOS/Generic")
        }
        
        return result
    }
    
    // MARK: Map device model to device name
    private static func modelName(from deviceId: String) -> String {
        switch deviceId {
            // iPod touch
            case "iPod1,1":
                return "iPod touch"
            case "iPod2,1":
                return "iPod touch (2nd generation)"
            case "iPod3,1":
                return "iPod touch (3rd generation)"
            case "iPod4,1":
                return "iPod touch (4th generation)"
            case "iPod5,1":
                return "iPod touch (5th generation)"
            case "iPod7,1":                                       
                return "iPod touch (6th generation)"
            case "iPod9,1":                                       
                return "iPod touch (7th generation)"
            
            // iPhone
            case "iPhone1,1":
                return "iPhone"
            case "iPhone1,2":
                return "iPhone 3G"
            case "iPhone2,1":
                return "iPhone 3GS"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":
                return "iPhone 4"
            case "iPhone4,1":                                     
                return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        
                return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        
                return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        
                return "iPhone 5s"
            case "iPhone7,2":                                     
                return "iPhone 6"
            case "iPhone7,1":                                     
                return "iPhone 6 Plus"
            case "iPhone8,1":                                     
                return "iPhone 6s"
            case "iPhone8,2":                                     
                return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        
                return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        
                return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      
                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      
                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      
                return "iPhone X"
            case "iPhone11,2":                                    
                return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      
                return "iPhone XS Max"
            case "iPhone11,8":                                    
                return "iPhone XR"
            case "iPhone12,1":                                    
                return "iPhone 11"
            case "iPhone12,3":                                    
                return "iPhone 11 Pro"
            case "iPhone12,5":                                    
                return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    
                return "iPhone 12 mini"
            case "iPhone13,2":                                    
                return "iPhone 12"
            case "iPhone13,3":                                    
                return "iPhone 12 Pro"
            case "iPhone13,4":                                    
                return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    
                return "iPhone 13 mini"
            case "iPhone14,5":                                    
                return "iPhone 13"
            case "iPhone14,2":                                    
                return "iPhone 13 Pro"
            case "iPhone14,3":                                    
                return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    
                return "iPhone 14"
            case "iPhone14,8":                                    
                return "iPhone 14 Plus"
            case "iPhone15,2":                                    
                return "iPhone 14 Pro"
            case "iPhone15,3":                                    
                return "iPhone 14 Pro Max"
            case "iPhone15,4":                                    
                return "iPhone 15"
            case "iPhone15,5":                                    
                return "iPhone 15 Plus"
            case "iPhone16,1":                                    
                return "iPhone 15 Pro"
            case "iPhone16,2":                                    
                return "iPhone 15 Pro Max"
            case "iPhone17,1":
                return "iPhone 16 Pro"
            case "iPhone17,2":
                return "iPhone 16 Pro Max"
            case "iPhone17,3":
                return "iPhone 16"
            case "iPhone17,4":
                return "iPhone 16 Plus"
            case "iPhone8,4":
                return "iPhone SE"
            case "iPhone12,8":                                    
                return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    
                return "iPhone SE (3rd generation)"
            
            // iPad
            case "iPad1,1":
                return "iPad"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
                return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 
                return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 
                return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          
                return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            
                return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          
                return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          
                return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          
                return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                        
                return "iPad (10th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 
                return "iPad Air"
            case "iPad5,3", "iPad5,4":                            
                return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          
                return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          
                return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        
                return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 
                return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 
                return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 
                return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            
                return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          
                return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          
                return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            
                return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            
                return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      
                return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           
                return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  
                return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                          
                return "iPad Pro (11-inch) (4th generation)"
            case "iPad6,7", "iPad6,8":                            
                return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            
                return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      
                return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          
                return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":
                return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                          
                return "iPad Pro (12.9-inch) (6th generation)"
            case "iPad16,3", "iPad16,4":
                return "iPad Pro (11-inch) (5th generation)"
            case "iPad16,5", "iPad16,6":
                return "iPad Pro (12.9 inch) (7th generation)"
            
            // Apple Watch
            case "Watch1,1", "Watch1,2":
                return "Apple Watch (1st generation)"
            case "Watch2,6", "Watch2,7":
                return "Apple Watch Series 1"
            case "Watch2,3", "Watch2,4":
                return "Apple Watch Series 2"
            case "Watch3,1", "Watch3,2", "Watch3,3", "Watch3,4":
                return "Apple Watch Series 3"
            case "Watch4,1", "Watch4,2", "Watch4,3", "Watch4,4":
                return "Apple Watch Series 4"
            case "Watch5,1", "Watch5,2", "Watch5,3", "Watch5,4":
                return "Apple Watch Series 5"
            case "Watch5,9", "Watch5,10", "Watch5,11", "Watch5,12":
                return "Apple Watch SE"
            case "Watch6,1", "Watch6,2", "Watch6,3", "Watch6,4":
                return "Apple Watch Series 6"
            case "Watch6,6", "Watch6,7", "Watch6,8", "Watch6,9":
                return "Apple Watch Series 7"
            case "Watch6,10", "Watch6,11", "Watch6,12", "Watch6,13":
                return "Apple Watch SE (2nd generation)"
            case "Watch6,14", "Watch6,15", "Watch6,16", "Watch6,17":
                return "Apple Watch Series 8"
            case "Watch6,18":
                return "Apple Watch Ultra"
            case "Watch7,1", "Watch7,2", "Watch7,3", "Watch7,4":
                return "Apple Watch Series 9"
            case "Watch7,5":
                return "Apple Watch Ultra 2"
            case "Watch7,8", "Watch7,9", "Watch7,10", "Watch7,11":
                return "Apple Watch Series 10"
            
            // Apple TV
            case "AppleTV5,3":
                return "Apple TV"
            case "AppleTV6,2":                                    
                return "Apple TV 4K"
            case "AppleTV11,1":
                return "Apple TV 4K (2nd generation)"
            
            // HomePod
            case "AudioAccessory1,1":                             
                return "HomePod"
            case "AudioAccessory5,1":                             
                return "HomePod mini"
            
            // Vision Pro
            case "RealityDevice14,1":
                return "Apple Vision Pro"
                
            default:
                return deviceId
        }
    }
}
