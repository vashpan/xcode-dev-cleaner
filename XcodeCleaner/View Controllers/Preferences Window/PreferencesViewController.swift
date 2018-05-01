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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: load preferences/set defaults
    }
}
