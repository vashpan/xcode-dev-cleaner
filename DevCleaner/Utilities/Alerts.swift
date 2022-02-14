//
//  Alerts.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 18.03.2018.
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

import Foundation
import Cocoa

public class Alerts {
    class public func fatalErrorAlertAndQuit(title: String, message: String) {
        // display a popup that tells us that this is basically a fatal error, and quit!
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "Quit")
        
        alert.runModal()
        NSApp.terminate(nil)
    }
    
    class public func warningAlert(title: String, message: String, okButtonText: String = "OK", cancelButtonText: String = "Cancel", window: NSWindow? = nil, completionHandler: ((NSApplication.ModalResponse) -> Void)? = nil) {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: okButtonText)
        alert.addButton(withTitle: cancelButtonText)
        
        if let currentWindow = window {
            alert.beginSheetModal(for: currentWindow, completionHandler: completionHandler)
        } else {
            let response = alert.runModal()
            completionHandler?(response)
        }
    }
    
    class public func infoAlert(title: String, message: String, okButtonText: String = "OK") {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: okButtonText)
        
        alert.runModal()
    }
}
