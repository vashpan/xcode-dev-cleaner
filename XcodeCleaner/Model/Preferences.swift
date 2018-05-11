//
//  Preferences.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 01.05.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

public final class Preferences {
    // MARK: Properties & constants
    public static let shared = Preferences()
    
    private let notificationsEnabledKey = "NotificationsEnabledKey"
    private let notificationsPeriodKey = "NotificationsPeriodKey"
    private let dryRunEnabledKey = "DryRunEnabledKey"
    
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
}
