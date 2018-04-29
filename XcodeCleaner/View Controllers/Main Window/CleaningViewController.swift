//
//  CleaningViewController.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 29.04.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

final class CleaningViewController: NSViewController {
    // MARK: Properties & outlets
    @IBOutlet private weak var currentFileLabel: NSTextField!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var doneButton: NSButton!
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.doneButton.isEnabled = true
    }
}
