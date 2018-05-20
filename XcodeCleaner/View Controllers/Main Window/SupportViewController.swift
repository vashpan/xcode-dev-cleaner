//
//  SupportViewController.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 19.05.2018.
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

internal final class SupportViewController: NSViewController {
    // MARK: Properties & outlets
    @IBOutlet weak var xcodeCleanerBenefitsTextField: NSTextField!
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update benefits label
        let totalBytesString = ByteCountFormatter.string(fromByteCount: Preferences.shared.totalBytesCleaned, countStyle: .file)
        self.xcodeCleanerBenefitsTextField.stringValue = "You saved total of \(totalBytesString) thanks to XcodeCleaner!"
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.styleMask.remove(.resizable)
    }
}
