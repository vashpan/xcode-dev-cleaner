//
//  ScanReminders.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 11.05.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation
import Cocoa
import NotificationCenter

public final class ScanReminders {
    // MARK: Types
    public enum Period: Int {
        case every2weeks, everyMonth, every2Months
        
        internal var repeatInterval: DateComponents {
            var result = DateComponents()
            
            #if DEBUG
            result.day = 1 // for debug we change our periods to one day
            #else
            switch self {
                case .every2weeks:
                    result.day = 7 * 2
                case .everyMonth:
                    result.month = 1
                case .every2Months:
                    result.month = 2
            }
            #endif
            
            return result
        }
    }
    
    // MARK: Constants
    private static let reminderIdentifier = "com.oneminutegames.XcodeCleaner.scanReminder"
    
    // MARK: Manage reminders
    public static func scheduleReminder(period: Period) {
        // notification
        let notification = NSUserNotification()
        notification.identifier = reminderIdentifier
        notification.title = "Scan Xcode cache?"
        notification.informativeText = "It's been a while since your last scan, check if you can reclaim some storage."
        notification.soundName = NSUserNotificationDefaultSoundName
        
        // buttons
        notification.hasActionButton = true
        notification.otherButtonTitle = "Close"
        notification.actionButtonTitle = "Scan"
        
        // schedule & repeat periodically
        if let initialDeliveryDate = NSCalendar.current.date(byAdding: period.repeatInterval, to: Date()) {
            notification.deliveryDate = initialDeliveryDate
            notification.deliveryRepeatInterval = period.repeatInterval
        }
        
        // schedule a notification
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.scheduleNotification(notification)
    }
    
    public static func disableReminder() {
        NSUserNotificationCenter.default.scheduledNotifications = []
    }
}
