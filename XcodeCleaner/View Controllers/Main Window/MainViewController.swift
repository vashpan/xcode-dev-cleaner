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
    @IBOutlet private weak var donationEncourageLabel: NSTextField!
    
    @IBOutlet private weak var bytesSelectedTextField: NSTextField!
    @IBOutlet private weak var totalBytesTextField: NSTextField!
    
    @IBOutlet private weak var xcodeVersionsTextField: NSTextField!
    
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var cleanButton: NSButton!
    
    private let xcodeFiles = XcodeFiles()
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let xcodeFiles = self.xcodeFiles else {
            log.error("MainViewController: Cannot create XcodeFiles instance!")
            return
        }
        
        xcodeFiles.delegate = self
        
        // check for installed Xcode versions
        self.checkForInstalledXcodes()
        
        // start initial scan
        self.startScan()
    }
    
    private func startScan() {
        guard let xcodeFiles = self.xcodeFiles else {
            log.error("MainViewController: Cannot create XcodeFiles instance!")
            return
        }
        
        self.startLoading()
        DispatchQueue.global(qos: .userInitiated).async {
            xcodeFiles.scanFiles(in: XcodeFiles.Location.all)
            
            self.stopLoading()
        }
    }
    
    // MARK: Helpers
    private func checkForInstalledXcodes() {
        guard let xcodeFiles = self.xcodeFiles else {
            log.error("MainViewController: Cannot create XcodeFiles instance!")
            return
        }
        
        xcodeFiles.checkForInstalledXcodes { (installedXcodeVersions) in
            var versionsText = String()
            
            var i = 0
            for version in installedXcodeVersions {
                if i == 0 {
                    versionsText = version.description
                } else {
                    versionsText += ", " + version.description
                }
                
                i += 1
            }
            
            self.xcodeVersionsTextField.stringValue = versionsText
        }
    }
    
    private func startLoading() {
        DispatchQueue.main.async {
            self.progressIndicator.isHidden = false
            self.progressIndicator.startAnimation(nil)
            
            self.cleanButton.isEnabled = false
        }
    }
    
    private func stopLoading() {
        DispatchQueue.main.async {
            self.progressIndicator.stopAnimation(nil)
            self.progressIndicator.isHidden = true
            
            self.cleanButton.isEnabled = true
        }
    }
    
    // MARK: Actions
    @IBAction func cleanButtonPressed(_ sender: NSButton) {
        log.info("MainViewController: 'Clean' button action not implemented yet!")
    }
    
    @IBAction func donateButtonPressed(_ sender: NSButton) {
        log.info("MainViewController: 'Donate...' button action not implemented yet!")
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
