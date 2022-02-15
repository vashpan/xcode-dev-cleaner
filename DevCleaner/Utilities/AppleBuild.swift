//
//  AppleBuild.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 15/02/2022.
//  Copyright © 2022 One Minute Games. All rights reserved.
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

// MARK: AppleBuild struct
public struct AppleBuild {
    // MARK: Properties
    public let textual: String
    
    public let major: Int?
    public let minor: Character?
    public let daily: String?
    
    // MARK: Constants
    public static let empty = AppleBuild()
    
    // MARK: Initialization
    init() {
        self.textual = String()
        
        self.major = nil
        self.minor = nil
        self.daily = nil
    }
    
    init(string: String) {
        self.textual = string
        
        // parse build number according to this:
        // https://tidbits.com/2020/07/08/how-to-decode-apple-version-and-build-numbers/
        let scanner = Scanner(string: self.textual)
        scanner.caseSensitive = false
        
        self.major = scanner.scanInt()
        self.minor = scanner.scanCharacter()
        self.daily = scanner.string[scanner.currentIndex...].description
    }
}

// MARK: - Comparable implementation
extension AppleBuild: Comparable {
    public static func ==(lhs: AppleBuild, rhs: AppleBuild) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                let lhsDaily = lhs.daily ?? ""
                let rhsDaily = rhs.daily ?? ""
                
                if lhsDaily == rhsDaily {
                    return true
                }
            }
        }
        
        return false
    }
    
    public static func <(lhs: AppleBuild, rhs: AppleBuild) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                let lhsDaily = lhs.daily ?? ""
                let rhsDaily = rhs.daily ?? ""
                
                return lhsDaily.compare(rhsDaily) == .orderedAscending
            } else {
                let lhsMinor = lhs.minor ?? Character("")
                let rhsMinor = rhs.minor ?? Character("")
                
                return lhsMinor < rhsMinor
            }
        } else {
            let lhsMajor = lhs.major ?? 0
            let rhsMajor = rhs.major ?? 0
            
            return lhsMajor < rhsMajor
        }
    }
}

// MARK: - CustomStringConvertible conformance
extension AppleBuild: CustomStringConvertible {
    public var description: String {
        return self.textual
    }
}
