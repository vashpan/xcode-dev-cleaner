//
//  Preferences.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 01.05.2018.
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

public final class Preferences {
    // MARK: Properties & constants
    public static let shared = Preferences()
    
    private let notificationsEnabledKey = "DCNotificationsEnabledKey"
    private let notificationsPeriodKey = "DCNotificationsPeriodKey"
    private let dryRunEnabledKey = "DCDryRunEnabledKey"
    private let totalBytesCleanedKey = "DCTotalBytesCleaned"
    private let customArchivesFolderKey = "DCCustomArchivesFolderKey"
    private let customDerivedDataFolderKey = "DCCustomDerivedDataFolderKey"
    
    // MARK: Initialization
    public init() {
        
    }
    
    // MARK: Environment
    public func envValue(key: String) -> String? {
        return ProcessInfo.processInfo.environment[key]
    }
    
    public func envKeyPresent(key: String) -> Bool {
        return ProcessInfo.processInfo.environment.keys.contains(key)
    }
    
    // MARK: Options
    public var notificationsEnabled: Bool {
        get {
            guard UserDefaults.standard.object(forKey: notificationsEnabledKey) != nil else {
                return true // default value
            }
            
            return UserDefaults.standard.bool(forKey: notificationsEnabledKey)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: notificationsEnabledKey)
        }
    }
    
    public var notificationsPeriod: ScanReminders.Period {
        get {
            guard UserDefaults.standard.object(forKey: notificationsPeriodKey) != nil else {
                return .everyMonth
            }
            
            let periodInt = UserDefaults.standard.integer(forKey: notificationsPeriodKey)
            
            guard let period = ScanReminders.Period(rawValue: periodInt) else {
                return .everyMonth
            }
            
            return period
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: notificationsPeriodKey)
        }
    }
    
    public var dryRunEnabled: Bool {
        get {
            guard UserDefaults.standard.object(forKey: dryRunEnabledKey) != nil else {
                #if DEBUG
                return true // default value
                #else
                return false
                #endif 
            }
            
            return UserDefaults.standard.bool(forKey: dryRunEnabledKey)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: dryRunEnabledKey)
        }
    }
    
    public var totalBytesCleaned: Int64 {
        get {
            if let value = UserDefaults.standard.object(forKey: totalBytesCleanedKey) as? NSNumber {
                return value.int64Value
            }
            
            return 0
        }
        
        set {
            let numberValue = NSNumber(value: newValue)
            UserDefaults.standard.set(numberValue, forKey: totalBytesCleanedKey)
        }
    }
    
    public var customArchivesFolder: URL? {
        get {
            if let archives = UserDefaults.standard.object(forKey: customArchivesFolderKey) as? URL {
                return archives
            }
            
            return nil
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: customArchivesFolderKey)
        }
    }
    
    public var customDerivedDataFolder: URL? {
        get {
            if let derivedData = UserDefaults.standard.object(forKey: customDerivedDataFolderKey) as? URL {
                return derivedData
            }
            
            return nil
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: customDerivedDataFolderKey)
        }
    }
    
    // MARK: Folder bookmarks
    private func folderBookmarkKey(for url: URL) -> String {
        return "DCFolderBookmark_\(url.absoluteString.md5)"
    }
    
    public func folderBookmark(for url: URL) -> Data? {
        let key = self.folderBookmarkKey(for: url)
        return UserDefaults.standard.data(forKey: key)
    }
    
    public func setFolderBookmark(bookmarkData: Data?, for url: URL) {
        let key = self.folderBookmarkKey(for: url)
        UserDefaults.standard.set(bookmarkData, forKey: key)
    }
}
