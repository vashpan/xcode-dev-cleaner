//
//  CmdLineTool.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 20/08/2019.
//  Copyright © 2019 One Minute Games. All rights reserved.
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

final class CmdLineTool {
    // MARK: Helpers
    private static func printAppInfo() {
        guard let bundleInfoDictionary = Bundle.main.infoDictionary else {
            fatalError("CmdLineTool: No Info.plist in main app bundle!?")
        }
        
        guard let appVersion = bundleInfoDictionary["CFBundleShortVersionString"] as? String else {
            fatalError("CmdLineTool: Can't get app version from main bundle!")
        }
        
        guard let appBuildNumber = bundleInfoDictionary["CFBundleVersion"] as? String else {
            fatalError("CmdLineTool: Can't get app build number from main bundle!")
        }
        
        print("DevCleaner \(appVersion) (\(appBuildNumber))")
        print("Command line mode.")
        print()
    }
    
    // MARK: Start command line tool
    static func start(args: [String]) {
        printAppInfo()
    }
}
