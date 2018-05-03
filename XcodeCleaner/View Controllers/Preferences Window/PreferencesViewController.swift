//
//  PreferencesViewController.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 01.05.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

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
    private func titleFromPeriod(_ period: Preferences.NotificationsPeriod) -> String {
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
    
    private func periodFromTitle(_ title: String) -> Preferences.NotificationsPeriod? {
        let result: Preferences.NotificationsPeriod?
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
    
    private func setNotificationsPeriod(_ period: Preferences.NotificationsPeriod) {
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
    }
    
    @IBAction func updatePeriod(_ sender: NSPopUpButton) {
        guard let selectedItem = sender.selectedItem else {
            return
        }
        
        guard let selectedPeriod = self.periodFromTitle(selectedItem.title) else {
            return
        }
        
        Preferences.shared.notificationsPeriod = selectedPeriod
    }
    
    @IBAction func updateDryRun(_ sender: NSButton) {
        let enabled = sender.state == .on
        
        self.setDryRunEnabled(enabled)
        
        Preferences.shared.dryRunEnabled = enabled
    }
}
