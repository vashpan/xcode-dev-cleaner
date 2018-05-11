//
//  XcodeFinder.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 04.05.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

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
