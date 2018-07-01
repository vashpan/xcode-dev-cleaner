//
//  PreferencesViewController.swift
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

import Cocoa

final class PreferencesViewController: NSViewController {
    // MARK: Properties & outlets
    @IBOutlet private weak var notificationsEnabledButton: NSButton!
    @IBOutlet private weak var notificationsPeriodPopUpButton: NSPopUpButton!
    
    @IBOutlet private weak var dryRunEnabledButton: NSButton!
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load preferences
        self.setNotificationsEnabled(Preferences.shared.notificationsEnabled)
        self.setNotificationsPeriod(Preferences.shared.notificationsPeriod)
        self.setDryRunEnabled(Preferences.shared.dryRunEnabled)
    }
    
    // MARK: Helpers
    private func titleFromPeriod(_ period: ScanReminders.Period) -> String {
        let result: String
        switch period {
            case .every2weeks:
                result = "Every 2 weeks"
            case .everyMonth:
                result = "Every month"
            case .every2Months:
                result = "Every 2 months"
        }
        
        return result
    }
    
    private func periodFromTitle(_ title: String) -> ScanReminders.Period? {
        let result: ScanReminders.Period?
        switch title {
            case "Every 2 weeks":
                result = .every2weeks
            case "Every month":
                result = .everyMonth
            case "Every 2 months":
                result = .every2Months
            default:
                result = nil
        }
        
        return result
    }
    
    private func setNotificationsEnabled(_ value:  Bool) {
        self.notificationsEnabledButton.state = value ? .on : .off
        self.notificationsPeriodPopUpButton.isEnabled = value
    }
    
    private func setNotificationsPeriod(_ period: ScanReminders.Period) {
        let periodTitle = self.titleFromPeriod(period)
        self.notificationsPeriodPopUpButton.selectItem(withTitle: periodTitle)
    }
    
    private func setDryRunEnabled(_ value: Bool) {
        self.dryRunEnabledButton.state = value ? .on : .off
    }
    
    // MARK: Actions
    @IBAction func updateNotificationsEnabled(_ sender: NSButton) {
        let enabled = sender.state == .on
        
        self.setNotificationsEnabled(enabled)
        
        Preferences.shared.notificationsEnabled = enabled
        
        if enabled {
            ScanReminders.scheduleReminder(period: Preferences.shared.notificationsPeriod)
        } else {
            ScanReminders.disableReminder()
        }
    }
    
    @IBAction func updatePeriod(_ sender: NSPopUpButton) {
        guard let selectedItem = sender.selectedItem else {
            return
        }
        
        guard let selectedPeriod = self.periodFromTitle(selectedItem.title) else {
            return
        }
        
        Preferences.shared.notificationsPeriod = selectedPeriod
        ScanReminders.scheduleReminder(period: Preferences.shared.notificationsPeriod)
    }
    
    @IBAction func updateDryRun(_ sender: NSButton) {
        let enabled = sender.state == .on
        
        self.setDryRunEnabled(enabled)
        
        Preferences.shared.dryRunEnabled = enabled
    }
}
