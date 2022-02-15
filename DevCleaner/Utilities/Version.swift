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
    
    init?(describing: String) {
        let components = describing.split(separator: ".", maxSplits: 3, omittingEmptySubsequences: true)
        
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

