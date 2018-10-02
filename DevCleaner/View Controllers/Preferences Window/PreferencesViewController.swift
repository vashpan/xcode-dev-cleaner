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
    // MARK: Types
    private enum CustomLocation {
        case `default`
        case custom
    }
    
    // MARK: Properties & outlets
    @IBOutlet private weak var notificationsEnabledButton: NSButton!
    @IBOutlet private weak var notificationsPeriodPopUpButton: NSPopUpButton!
    
    @IBOutlet private weak var dryRunEnabledButton: NSButton!
    
    @IBOutlet private weak var customDerivedDataTextField: NSTextField!
    @IBOutlet private weak var customArchivesTextField: NSTextField!
    
    @IBOutlet private weak var archivesPopUpButton: NSPopUpButton!
    @IBOutlet private weak var derivedDataPopUpButton: NSPopUpButton!
    
    @IBOutlet private weak var changeCustomDerivedDataButton: NSButton!
    @IBOutlet private weak var changeCustomArchivesButton: NSButton!
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load preferences
        self.setNotificationsEnabled(Preferences.shared.notificationsEnabled)
        self.setNotificationsPeriod(Preferences.shared.notificationsPeriod)
        self.setDryRunEnabled(Preferences.shared.dryRunEnabled)
        self.setCustomDerivedData(folder: Preferences.shared.customDerivedDataFolder)
        self.setCustomArchives(folder: Preferences.shared.customArchivesFolder)
    }
    
    // MARK: Helpers
    private func xcodeDefaultFolder(appending path: String) -> URL {
        let userName = NSUserName()
        let userHomeDirectory = URL(fileURLWithPath: "/Users/\(userName)")
        let xcodeDeveloperFolder = userHomeDirectory.appendingPathComponent("Library/Developer/Xcode", isDirectory: true)
        
        return xcodeDeveloperFolder.appendingPathComponent(path)
    }
    
    private func customFolderLocationFromTitle(_ title: String) -> CustomLocation? {
        let result: CustomLocation?
        switch title {
            case "Default":
                result = .default
            case "Custom":
                result = .custom
            default:
                result = nil
        }
        
        return result
    }
    
    private func titleFromCustomFolderLocation(_ location: CustomLocation) -> String {
        let result: String
        switch location {
            case .custom:
                result = "Custom"
            case .default:
                result = "Default"
        }
        
        return result
    }
    
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
    
    private func setCustomDerivedData(folder: URL?) {
        if let customFolder = folder {
            self.customDerivedDataTextField.stringValue = customFolder.path
            self.customDerivedDataTextField.toolTip = customFolder.path
            
            self.derivedDataPopUpButton.selectItem(withTitle: self.titleFromCustomFolderLocation(.custom))
            self.customDerivedDataTextField.isEnabled = true
            self.changeCustomDerivedDataButton.isEnabled = true
        } else {
            let defaultFolder = self.xcodeDefaultFolder(appending: "DerivedData").path
            self.customDerivedDataTextField.stringValue = defaultFolder
            self.customDerivedDataTextField.toolTip = defaultFolder
            
            self.derivedDataPopUpButton.selectItem(withTitle: self.titleFromCustomFolderLocation(.default))
            self.changeCustomDerivedDataButton.isEnabled = false
            self.customDerivedDataTextField.isEnabled = false
        }
    }
    
    private func setCustomArchives(folder: URL?) {
        if let customFolder = folder {
            self.customArchivesTextField.stringValue = customFolder.path
            self.customArchivesTextField.toolTip = customFolder.path
            
            self.archivesPopUpButton.selectItem(withTitle: self.titleFromCustomFolderLocation(.custom))
            self.customArchivesTextField.isEnabled = true
            self.changeCustomArchivesButton.isEnabled = true
        } else {
            let defaultFolder = self.xcodeDefaultFolder(appending: "Archives").path
            self.customArchivesTextField.stringValue = defaultFolder
            self.customArchivesTextField.toolTip = defaultFolder
            
            self.archivesPopUpButton.selectItem(withTitle: self.titleFromCustomFolderLocation(.default))
            self.customArchivesTextField.isEnabled = false
            self.changeCustomArchivesButton.isEnabled = false
        }
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
    
    @IBAction func changeDerivedDataFolder(_ sender: NSPopUpButton) {
        guard let selectedItem = sender.selectedItem else {
            return
        }
        
        guard let location = self.customFolderLocationFromTitle(selectedItem.title) else {
            return
        }
        
        switch location {
            case .default:
                Preferences.shared.customDerivedDataFolder = nil
                
                self.changeCustomDerivedDataButton.isEnabled = false
                self.customDerivedDataTextField.isEnabled = false
                self.customDerivedDataTextField.stringValue = self.xcodeDefaultFolder(appending: "DerivedData").path
            case .custom:
                let folderUrl = URL(fileURLWithPath: self.customDerivedDataTextField.stringValue, isDirectory: true)
                Preferences.shared.customDerivedDataFolder = folderUrl
                
                self.customDerivedDataTextField.isEnabled = true
                self.changeCustomDerivedDataButton.isEnabled = true
        }
    }
    
    @IBAction func changeArchivesFolder(_ sender: NSPopUpButton) {
        guard let selectedItem = sender.selectedItem else {
            return
        }
        
        guard let location = self.customFolderLocationFromTitle(selectedItem.title) else {
            return
        }
        
        switch location {
        case .default:
            Preferences.shared.customArchivesFolder = nil
            
            self.changeCustomArchivesButton.isEnabled = false
            self.customArchivesTextField.isEnabled = false
            self.customArchivesTextField.stringValue = self.xcodeDefaultFolder(appending: "Archives").path
        case .custom:
            let folderUrl = URL(fileURLWithPath: self.customArchivesTextField.stringValue, isDirectory: true)
            Preferences.shared.customArchivesFolder = folderUrl
            
            self.customArchivesTextField.isEnabled = true
            self.changeCustomArchivesButton.isEnabled = true
        }
    }
}
