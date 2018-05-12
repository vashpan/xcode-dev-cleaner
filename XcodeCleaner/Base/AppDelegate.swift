//
//  AppDelegate.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 11.02.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

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
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

