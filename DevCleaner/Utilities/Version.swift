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
    public var major: UInt { return components[0] }
    public var minor: UInt { return components[1] }
    public var patch: UInt? { return components.count == 3 ? components[2] : nil }

    // contains 2 or 3 items only
    private let components: [UInt]

    // MARK: Initialization
    init(major: UInt, minor: UInt, patch: UInt? = nil) {
        components = [major, minor, patch].compactMap { $0 }
    }

    init?(describing: String) {
        let stringComponents = describing.split(separator: ".", maxSplits: 3, omittingEmptySubsequences: true).map(String.init)
        guard 2...3 ~= stringComponents.count else { return nil }
        let optionalUIntComponents = stringComponents.map(UInt.init)
        guard optionalUIntComponents.first(where: { $0 == nil }) == nil else { return nil }
        components = optionalUIntComponents.compactMap { $0 }
    }
}

// MARK: Comparable implementation
extension Version: Comparable {
    public static func ==(lhs: Version, rhs: Version) -> Bool {
        return lhs.minor == rhs.minor &&
               lhs.minor == rhs.minor &&
               lhs.patch ?? 0 == rhs.patch ?? 0
    }

    public static func <(lhs: Version, rhs: Version) -> Bool {
        return lhs.description.compare(rhs.description, options: .numeric) == .orderedAscending
    }
}

// MARK: CustomStringConvertible conformance
extension Version: CustomStringConvertible {
    public var description: String {
        return components.map(String.init).joined(separator: ".")
    }
}
