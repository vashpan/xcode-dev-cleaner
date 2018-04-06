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
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    private let xcodeFiles = XcodeFiles()
    private var scanCounter = 0
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()

        xcodeFiles?.delegate = self
        
        self.loadingIndicator.isHidden = true
    }

    // MARK: Helpers
    private func startLoading() {
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimation(nil)
    }
    
    private func stopLoading() {
        self.loadingIndicator.stopAnimation(nil)
        self.loadingIndicator.isHidden = true
    }
    
    // MARK: Actions
    @IBAction func openButtonPressed(_ sender: NSButton) {

    }
    
    @IBAction func testButtonPressed(_ sender: NSButton) {
        guard let xcodeFiles = self.xcodeFiles else {
            log.error("Cannot create XcodeFiles instance!")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.scanCounter = 4
            
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
        self.startLoading()
    }
    
    func scanDidFinish(for location: XcodeFiles.Location, entry: XcodeFileEntry) {
        scanCounter -= 1
        if scanCounter == 0 {
            self.stopLoading()
            
            if let xcodeFiles = self.xcodeFiles {
                print(xcodeFiles.debugRepresentation())
            }
        }
    }
}

