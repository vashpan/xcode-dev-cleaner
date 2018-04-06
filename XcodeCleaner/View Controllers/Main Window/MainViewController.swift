//
//  MainViewController.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 11.02.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

final class MainViewController: NSViewController {
    // MARK: Properties & outlets
    private let xcodeFiles = XcodeFiles()
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()

        xcodeFiles?.delegate = self
    }
    
    // MARK: Actions
    @IBAction func scanButtonPressed(_ sender: NSButton) {
        guard let xcodeFiles = self.xcodeFiles else {
            log.error("Cannot create XcodeFiles instance!")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            xcodeFiles.scanFiles(in: .deviceSupport)
            xcodeFiles.scanFiles(in: .derivedData)
            xcodeFiles.scanFiles(in: .archives)
            xcodeFiles.scanFiles(in: .simulators)
        }
    }
}

// MARK: XcodeFilesDelegate implementation
extension MainViewController: XcodeFilesDelegate {
    func scanWillBegin(for location: XcodeFiles.Location, entry: XcodeFileEntry) {
        
    }
    
    func scanDidFinish(for location: XcodeFiles.Location, entry: XcodeFileEntry) {
        print(entry.debugRepresentation())
    }
}
