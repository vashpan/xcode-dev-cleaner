//
//  ViewController.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 11.02.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    // MARK: Properties & outlets
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: Actions
    @IBAction func openButtonPressed(_ sender: NSButton) {

    }
    
    @IBAction func testButtonPressed(_ sender: NSButton) {
        guard let xcodeDevLocation = XcodeFiles.defaultXcodeCachesLocation else {
            NSLog("❌ Cannot recognize default caches location!")
            return
        }
        
        guard let xcodeFiles = XcodeFiles(xcodeDevLocation: xcodeDevLocation) else {
            NSLog("❌ Cannot create XcodeFiles instance!")
            return
        }
        
        xcodeFiles.scanFiles(in: .deviceSupport)
        
        if let deviceSupport = xcodeFiles.locations[.deviceSupport] {
            NSLog("\n\(deviceSupport.debugRepresentation())")
        }
    }
}

