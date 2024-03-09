//
//  CommandLineInstallViewController.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 06/03/2024.
//  Copyright © 2024 One Minute Games. All rights reserved.
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

final class CommandLineInstallViewController: NSViewController {
    // MARK: Properties & outlets
    @IBOutlet weak var commandTextField: NSTextField!
    
    private var commandString: String {
        let appPath = Bundle.main.bundlePath
        
        return "sudo ln -sf \(appPath)/Contents/Resources/dev-cleaner.sh /usr/local/bin/dev-cleaner"
    }
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commandTextField.stringValue = "$ " + self.commandString
        self.commandTextField.isSelectable = true
    }
    
    // MARK: Actions
    @IBAction func copyCommand(_ sender: Any) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        pasteboard.setString(self.commandString, forType: .string)
    }
}
