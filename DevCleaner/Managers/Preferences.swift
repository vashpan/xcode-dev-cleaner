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
    private let devFolderBookmarkDataKey = "DCDevFolderBookmarkDataKey"
    
    // MARK: Initialization
    public init() {
        
    }
    
    // MARK: Options
    public var notificationsEnabled: Bool {
        get {
            guard UserDefaults.standard.object(forKey: notificationsEnabledKey) != nil else {
                return false // default value
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
    
    public var devFoolderBookmark: Data? {
        get {
            return UserDefaults.standard.data(forKey: devFolderBookmarkDataKey)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: devFolderBookmarkDataKey)
        }
    }
}
