//
//  Version.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 18.03.2018.
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

// MARK: Version struct
public struct Version {
    // MARK: Properties
    public let major: UInt
    public let minor: UInt
    public let patch: UInt?
    
    // MARK: Initialization
    init(major: UInt, minor: UInt, patch: UInt? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    init?(string: String) {
        let components = string.split(separator: ".", maxSplits: 3, omittingEmptySubsequences: true)
        
        if components.count == 3 {
            if let majorInt = UInt(components[0]) {
                self.major = majorInt
            } else {
                return nil
            }
            
            if let minorInt = UInt(components[1]) {
                self.minor = minorInt
            } else {
                return nil
            }
            
            if let patchInt = UInt(components[2]) {
                self.patch = patchInt
            } else {
                return nil
            }
        } else if components.count == 2 {
            if let majorInt = UInt(components[0]) {
                self.major = majorInt
            } else {
                return nil
            }
            
            if let minorInt = UInt(components[1]) {
                self.minor = minorInt
            } else {
                return nil
            }
            
            self.patch = nil
            
        } else {
            return nil
        }
    }
    
    init?(osVersionRawString: String) {
        // regex to get version from strings like those: NSOperatingSystemVersion(majorVersion/ 16, minorVersion/ 2, patchVersion/ 0)
        let pattern = #"majorVersion[:/]\s*(\d+).*?minorVersion[:/]\s*(\d+).*?patchVersion[:/]\s*(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        
        let range = NSRange(osVersionRawString.startIndex..., in: osVersionRawString)
        guard let match = regex.firstMatch(in: osVersionRawString, range: range), match.numberOfRanges == 4 else { return nil }
        
        let nsString = osVersionRawString as NSString
        let major = nsString.substring(with: match.range(at: 1))
        let minor = nsString.substring(with: match.range(at: 2))
        let patch = nsString.substring(with: match.range(at: 3))
        
        // if we have "0" in patch, ignore it as Apple convention is to use 16.2 instead of 16.2.0
        let versionString: String
        if patch == "0" {
            versionString = "\(major).\(minor)"
        } else {
            versionString = "\(major).\(minor).\(patch)"
        }
        
        self.init(string: versionString)
    }
    
    init?(describing: String) {
        let isRawOSVersionString = describing.starts(with: "NSOperatingSystemVersion")
        switch isRawOSVersionString {
            case true: self.init(osVersionRawString: describing)
            case false: self.init(string: describing)
        }
    }
}

// MARK: - Comparable implementation
extension Version: Comparable {
    public static func ==(lhs: Version, rhs: Version) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                let lhsPatch = lhs.patch ?? 0
                let rhsPatch = rhs.patch ?? 0
                
                if lhsPatch == rhsPatch {
                    return true
                }
            }
        }
        
        return false
    }
    
    public static func <(lhs: Version, rhs: Version) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                let lhsPatch = lhs.patch ?? 0
                let rhsPatch = rhs.patch ?? 0
                
                return lhsPatch < rhsPatch
            } else {
                return lhs.minor < rhs.minor
            }
        } else {
            return lhs.major < rhs.major
        }
    }
}

// MARK: - CustomStringConvertible conformance
extension Version: CustomStringConvertible {
    public var description: String {
        var result = "\(self.major).\(self.minor)"
        if let patch = self.patch {
            result += ".\(patch)"
        }
        
        return result
    }
}

