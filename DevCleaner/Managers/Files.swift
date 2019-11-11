//
//  Files.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 26/08/2019.
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

public final class Files {
    // MARK: Paths to common folders
    public static var userDeveloperFolder: URL {
        let userHomeDirectory = FileManager.default.realHomeDirectoryForCurrentUser
        let userDeveloperFolder = userHomeDirectory.appendingPathComponent("Library/Developer", isDirectory: true)
        
        return userDeveloperFolder
    }
    
    public static var commandLineToolFolder: URL = URL(fileURLWithPath: "/usr/local/bin", isDirectory: true)
    
    // MARK: Acquire folder permissions
    private static func acquireFolderPermissions(folderUrl: URL, allowCancel: Bool = false, openPanelMessage: String? = nil) -> URL? {
        let message = openPanelMessage ??
                      "DevCleaner needs permission to this folder to scan its contents. Folder should be already selected and all you need to do is to click \"Open\"."
        
        return folderUrl.acquireAccessFromSandbox(bookmark: Preferences.shared.folderBookmark(for: folderUrl),
                                                  allowCancel: allowCancel,
                                                  openPanelMessage: message)
    }
    
    public static func aqcuireCommandLineToolFolderPermission() -> URL? {
        return acquireFolderPermissions(folderUrl: Files.commandLineToolFolder,
                                        allowCancel: true,
                                        openPanelMessage: "In order to install command line tool, DevCleaner needs permission to folder where you want to install it. You can choose a different one if you want, but then make sure it will be accessible from your PATH.")
    }
    
    public static func acquireUserDeveloperFolderPermissions() -> URL? {
        return acquireFolderPermissions(folderUrl: Files.userDeveloperFolder,
                                        openPanelMessage: "DevCleaner needs permission to your Developer folder to scan Xcode cache files. Folder should be already selected and all you need to do is to click \"Open\".")
    }
    
    public static func acquireCustomDerivedDataFolderPermissions() -> URL? {
        guard let customDerivedDataFolder = Preferences.shared.customDerivedDataFolder else {
            return nil
        }
        
        return acquireFolderPermissions(folderUrl: customDerivedDataFolder)
    }
    
    public static func acquireCustomArchivesFolderPermissions() -> URL? {
        guard let customArchivesFolder = Preferences.shared.customArchivesFolder else {
            return nil
        }
        
        return acquireFolderPermissions(folderUrl: customArchivesFolder)
    }
}
