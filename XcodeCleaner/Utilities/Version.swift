//
//  Version.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 18.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

// MARK: Version struct
public struct Version {
    // MARK: Properties
    public let major: UInt
    public let minor: UInt
    public let patch: UInt?
    
    public var description: String {
        var result = "\(self.major).\(self.minor)"
        if let patch = self.patch {
            result += ".\(patch)"
        }
        
        return result
    }
    
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

// MARK: Comparable implementation
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

// MARK: CustomStringConvertible conformance
extension Version: CustomStringConvertible {
    
}

