//
//  AppDelegate.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 11.02.2018.
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

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: App configuration
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // MARK: App lifetime events
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // register as transactions observer
        Donations.shared.startObservingTransactionsQueue()
        
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
    
    // MARK: Actions
    @IBAction func openAppReview(_ sender: Any) {
        ReviewRequests.shared.showReviewOnTheAppStore()
    }
    
    @IBAction func showLogFiles(_ sender: Any) {
        // logs folder
        guard let logsUrl = log.logFilePath?.deletingLastPathComponent() else {
            return
        }
        
        NSWorkspace.shared.openFile(logsUrl.path)
    }
    
    @IBAction func installCommandLineTool(_ sender: Any) {
        // acquire tool install path
        guard let toolInstallPath = Files.aqcuireCommandLineToolFolderPermission() else {
            Alerts.warningAlert(title: "Command line tool installation failed",
                              message: "You need to choose proper folder to install command line tool!")
            return
        }
        
        // get tool path
        guard let toolScriptPath = Bundle.main.url(forResource: "dev-cleaner", withExtension: "sh") else {
            Alerts.warningAlert(title: "Command line tool installation failed",
                              message: "Launch script cannot be found in resources folder!")
            return
        }
        
        // copy tool to proper folder
        do {
            try FileManager.default.copyItem(at: toolScriptPath, to: toolInstallPath.appendingPathComponent("dev-cleaner"))
        } catch(let error) {
            Alerts.warningAlert(title: "Command line tool installation failed",
                              message: "Can't copy tool to selected folder: \(error.localizedDescription)")
        }
        
        Alerts.infoAlert(title: "Command line tool installation",
                       message: "Tool installed successfully!")
    }
}

