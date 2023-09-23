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
    @IBOutlet private weak var xcodeWarningButton: NSButton!
    
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
        self.setXcodeWarningEnabled(Preferences.shared.showXcodeWarning)
        self.setCustomDerivedData(folder: Preferences.shared.customDerivedDataFolder)
        self.setCustomArchives(folder: Preferences.shared.customArchivesFolder)
    }
    
    // MARK: Helpers
    private func chooseAndBookmarkFolder(startWith folder: URL) -> URL? {
        func doWeHaveAccess(for path: String) -> Bool {
            let fm = FileManager.default
            
            return fm.isReadableFile(atPath: path) && fm.isWritableFile(atPath: path)
        }
        
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = folder
        openPanel.message = "Choose a new location"
        openPanel.prompt = "Choose"
        
        openPanel.allowedContentTypes = []
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseDirectories = true
        
        openPanel.runModal()
        
        // check if we get proper file & save bookmark to it
        if let folderUrl = openPanel.urls.first {
            if doWeHaveAccess(for: folderUrl.path) {
                if let bookmarkData = try? folderUrl.bookmarkData(options: [.withSecurityScope]) {
                    Preferences.shared.setFolderBookmark(bookmarkData: bookmarkData, for: folderUrl)
                    return folderUrl
                } else {
                    Alerts.infoAlert(title: "Can't choose this folder",
                                   message: "Some problem with security.")
                    
                    return nil
                }
            } else {
                Alerts.infoAlert(title: "Can't choose this folder",
                               message: "Access to this folder is denied.")
                
                return nil
            }
        }
        
        return nil
    }
    
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
            case .everyWeek:
                result = "Every week"
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
            case "Every week":
                result = .everyWeek
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
    
    private func setXcodeWarningEnabled(_ value: Bool) {
        self.xcodeWarningButton.state = value ? .on : .off
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
    
    @IBAction func updateXcodeWarning(_ sender: NSButton) {
        let enabled = sender.state == .on
        
        self.setXcodeWarningEnabled(enabled)
        
        Preferences.shared.showXcodeWarning = enabled
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
    
    @IBAction func selectCustomDerivedDataFolder(_ sender: NSButton) {
        let startFolder = URL(fileURLWithPath: self.customDerivedDataTextField.stringValue, isDirectory: true)
        if let selectedDerivedDataFolder = self.chooseAndBookmarkFolder(startWith: startFolder) {
            Preferences.shared.customDerivedDataFolder = selectedDerivedDataFolder
            
            self.customDerivedDataTextField.stringValue = selectedDerivedDataFolder.path
        }
    }
    
    @IBAction func selectCustomArchivesFolder(_ sender: NSButton) {
        let startFolder = URL(fileURLWithPath: self.customArchivesTextField.stringValue, isDirectory: true)
        if let selectedArchivesFolder = self.chooseAndBookmarkFolder(startWith: startFolder) {
            Preferences.shared.customArchivesFolder = selectedArchivesFolder
            
            self.customArchivesTextField.stringValue = selectedArchivesFolder.path
        }
    }
}
