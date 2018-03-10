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
        let xcodeDevLocation = XcodeFiles.defaultXcodeCachesLocation
        NSLog("Xcode dev location: \(String(describing: xcodeDevLocation))")
    }
    
    @IBAction func testButtonPressed(_ sender: NSButton) {
        NSLog("Test button pressed!")
    }
}

