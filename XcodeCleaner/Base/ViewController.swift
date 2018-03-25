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
        guard let xcodeFiles = XcodeFiles() else {
            log.error("Cannot create XcodeFiles instance!")
            return
        }
        
        xcodeFiles.scanFiles(in: .deviceSupport)
        xcodeFiles.scanFiles(in: .simulators)
        
        if let deviceSupport = xcodeFiles.locations[.deviceSupport] {
            log.info("\n\(deviceSupport.debugRepresentation())")
        }
        
        if let deviceSupport = xcodeFiles.locations[.simulators] {
            log.info("\n\(deviceSupport.debugRepresentation())")
        }
    }
}

