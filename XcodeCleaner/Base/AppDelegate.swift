//
//  AppDelegate.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 11.02.2018.
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

import Cocoa

let log = Logger(level: .info)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: App configuration
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // MARK: App lifetime events
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // update notifications
        if Preferences.shared.notificationsEnabled {
            ScanReminders.scheduleReminder(period: Preferences.shared.notificationsPeriod)
        } else {
            ScanReminders.disableReminder()
        }
        
        // information about upcoming notifications
        if let upcomingReminderDate = ScanReminders.dateOfNextReminder {
            log.info("Next reminder: \(upcomingReminderDate.description(with: Locale.current))")
        } else {
            log.info("No reminder scheduled!")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

