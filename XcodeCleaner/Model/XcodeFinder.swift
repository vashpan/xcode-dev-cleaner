//
//  XcodeFinder.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 04.05.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//
//  XcodeCleaner is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  XcodeCleaner is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with XcodeCleaner.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import Cocoa

final class XcodeFinder {
    // MARK: Searching for Xcodes
    public static func checkForInstalledXcodeVersion(completion: (Version?) -> Void) {
        // TODO: try to find ALL installed Xcodes, not only the one returned from NSWorkspace, Spotlight could be useful for that (NSMetadataQuery)
        
        // find Xcode bundle path & open it
        guard let xcodePath = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: "com.apple.dt.Xcode") else {
            completion(nil)
            return
        }
        
        guard let xcodeBundle = Bundle(path: xcodePath) else {
            completion(nil)
            return
        }
        
        // figure out a version from Xcode bundle
        guard let xcodeBundleInfo = xcodeBundle.infoDictionary else {
            completion(nil)
            return
        }
        
        guard let versionString = xcodeBundleInfo["CFBundleShortVersionString"] as? String, let version = Version(describing: versionString) else {
            completion(nil)
            return
        }
        
        completion(version)
    }
}
