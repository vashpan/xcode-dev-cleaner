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
        // Check for new format: NSOperatingSystemVersion(majorVersion: 16, minorVersion: 2, patchVersion: 0)
        let pattern = #"NSOperatingSystemVersion\s*\(\s*majorVersion:\s*(\d+),\s*minorVersion:\s*(\d+),\s*patchVersion:\s*(\d+)\s*\)"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        if let match = regex?.firstMatch(in: describing, options: [], range: NSRange(describing.startIndex..., in: describing)) {
            if let majorRange = Range(match.range(at: 1), in: describing),
               let minorRange = Range(match.range(at: 2), in: describing),
               let patchRange = Range(match.range(at: 3), in: describing),
               let major = UInt(describing[majorRange]),
               let minor = UInt(describing[minorRange]),
               let patch = UInt(describing[patchRange]) {
                self.major = major
                self.minor = minor
                self.patch = patch
                return
            }
        } else {
            // Fall back to legacy format (e.g., "15.4" or "15.4.1")
            let components = describing.split(separator: ".", maxSplits: 3, omittingEmptySubsequences: true)

            if components.count == 2 || components.count == 3 {
                guard let major = UInt(components[0]),
                      let minor = UInt(components[1]) else {
                    log.warning("Version: Invalid version parsing: \(describing)")
                    return nil
                }
                let patch = components.count == 3 ? UInt(components[2]) : nil

                self.major = major
                self.minor = minor
                self.patch = patch
                return
            }
        }
        log.warning("Version: Invalid version parsing: \(describing)")
        return nil
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

