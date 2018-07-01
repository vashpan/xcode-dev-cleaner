//
//  ScanReminders.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 11.05.2018.
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
    
    // MARK: Properties
    public static var dateOfNextReminder: Date? {
        if let firstScheduledNotification = NSUserNotificationCenter.default.scheduledNotifications.first {
            return firstScheduledNotification.deliveryDate
        } else {
            return nil
        }
    }
    
    // MARK: Constants
    private static let reminderIdentifier = "com.oneminutegames.DevCleaner.scanReminder"
    
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
