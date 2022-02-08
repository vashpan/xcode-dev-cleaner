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
import CryptoKit

// MARK: Preferences Observer
@objc public protocol PreferencesObserver: AnyObject {
    func preferenceDidChange(key: String)
}

// MARK: - Preferences Class
public final class Preferences {
    // MARK: Keys
    public struct Keys {
        public static let notificationsEnabled = "DCNotificationsEnabledKey"
        public static let notificationsPeriod = "DCNotificationsPeriodKey"
        public static let dryRunEnabled = "DCDryRunEnabledKey"
        public static let totalBytesCleaned = "DCTotalBytesCleaned"
        public static let cleansSinceLastReview = "DCCleansSinceLastReview"
        public static let customArchivesFolder = "DCCustomArchivesFolderKey"
        public static let customDerivedDataFolder = "DCCustomDerivedDataFolderKey"
        public static let appFolder = "DCAppFolder"
        
        fileprivate static func folderBookmarkKey(for url: URL) -> String {
            let urlStringData = Data(url.path.utf8)
            let sha256hash = SHA256.hash(data: urlStringData)
            
            return "DCFolderBookmark_\(sha256hash.hexStr)"
        }
    }
    
    // MARK: Properties & constants
    public static let shared = Preferences()
    
    private var observers = [Weak<PreferencesObserver>]()

    // MARK: Initialization
    public init() {
        
    }
    
    // MARK: Observers
    public func addObserver(_ observer: PreferencesObserver) {
        let weakObserver = Weak(value: observer)
        
        if !self.observers.contains(weakObserver) {
            self.observers.append(weakObserver)
        }
    }
    
    public func removeObserver(_ observer: PreferencesObserver) {
        let weakObserverToRemove = Weak(value: observer)
        
        self.observers.removeAll { (observer) -> Bool in
            return observer == weakObserverToRemove
        }
    }
    
    private func informAllObserversAboutChange(keyThatChanged: String) {
        for observer in self.observers {
            observer.value?.preferenceDidChange(key: keyThatChanged)
        }
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
            guard UserDefaults.standard.object(forKey: Keys.notificationsEnabled) != nil else {
                return true // default value
            }
            
            return UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.notificationsEnabled)
            self.informAllObserversAboutChange(keyThatChanged: Keys.notificationsEnabled)
        }
    }
    
    public var notificationsPeriod: ScanReminders.Period {
        get {
            guard UserDefaults.standard.object(forKey: Keys.notificationsPeriod) != nil else {
                return .everyMonth
            }
            
            let periodInt = UserDefaults.standard.integer(forKey: Keys.notificationsPeriod)
            
            guard let period = ScanReminders.Period(rawValue: periodInt) else {
                return .everyMonth
            }
            
            return period
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.notificationsPeriod)
            self.informAllObserversAboutChange(keyThatChanged: Keys.notificationsPeriod)
        }
    }
    
    public var dryRunEnabled: Bool {
        get {
            guard UserDefaults.standard.object(forKey: Keys.dryRunEnabled) != nil else {
                #if DEBUG
                return true // default value
                #else
                return false
                #endif 
            }
            
            return UserDefaults.standard.bool(forKey: Keys.dryRunEnabled)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.dryRunEnabled)
            self.informAllObserversAboutChange(keyThatChanged: Keys.dryRunEnabled)
        }
    }
    
    public var totalBytesCleaned: Int64 {
        get {
            if let value = UserDefaults.standard.object(forKey: Keys.totalBytesCleaned) as? NSNumber {
                return value.int64Value
            }
            
            return 0
        }
        
        set {
            let numberValue = NSNumber(value: newValue)
            UserDefaults.standard.set(numberValue, forKey: Keys.totalBytesCleaned)
            
            self.informAllObserversAboutChange(keyThatChanged: Keys.totalBytesCleaned)
        }
    }
    
    public var cleansSinceLastReview: Int {
        get {
            if let value = UserDefaults.standard.object(forKey: Keys.cleansSinceLastReview) as? NSNumber {
                return value.intValue
            }
            
            return 0
        }
        
        set {
            let numberValue = NSNumber(value: newValue)
            UserDefaults.standard.set(numberValue, forKey: Keys.cleansSinceLastReview)
            
            self.informAllObserversAboutChange(keyThatChanged: Keys.cleansSinceLastReview)
        }
    }
    
    public var customArchivesFolder: URL? {
        get {
            if let archivesPath = UserDefaults.standard.object(forKey: Keys.customArchivesFolder) as? String {
                return URL(fileURLWithPath: archivesPath)
            }
            
            return nil
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.customArchivesFolder)
            self.informAllObserversAboutChange(keyThatChanged: Keys.customArchivesFolder)
        }
    }
    
    public var customDerivedDataFolder: URL? {
        get {
            if let derivedDataPath = UserDefaults.standard.object(forKey: Keys.customDerivedDataFolder) as? String {
                return URL(fileURLWithPath: derivedDataPath)
            }
            
            return nil
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.customDerivedDataFolder)
            self.informAllObserversAboutChange(keyThatChanged: Keys.customDerivedDataFolder)
        }
    }
    
    public var appFolder: URL {
        get {
            if let appFolderPath = UserDefaults.standard.object(forKey: Keys.appFolder) as? String {
                return URL(fileURLWithPath: appFolderPath)
            }
            
            return Bundle.main.bundleURL
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.appFolder)
            self.informAllObserversAboutChange(keyThatChanged: Keys.appFolder)
        }
    }
    
    // MARK: Folder bookmarks
    public func folderBookmark(for url: URL) -> Data? {
        let key = Keys.folderBookmarkKey(for: url)
        return UserDefaults.standard.data(forKey: key)
    }
    
    public func setFolderBookmark(bookmarkData: Data?, for url: URL) {
        let key = Keys.folderBookmarkKey(for: url)
        UserDefaults.standard.set(bookmarkData, forKey: key)
    }
}
