//
//  CleaningViewController.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 29.04.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

internal final class CleaningViewController: NSViewController {
    // MARK: Types
    internal enum State {
        case undefined
        
        case idle(title: String, indeterminate: Bool, doneButtonEnabled: Bool)
        case working(title: String, details: String, progress: Double)
    }
    
    // MARK: Properties & outlets
    @IBOutlet private weak var currentFileLabel: NSTextField!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var doneButton: NSButton!
    
    internal var state: State = .undefined {
        didSet {
            if self.isViewLoaded {
                self.update(state: self.state)
            }
        }
    }
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update first state we set
        self.update(state: self.state)
    }
    
    // MARK: Updating state
    private func update(state: State) {
        switch state {
            case .idle(let title, let indeterminate, let doneButtonEnabled):
                self.doneButton.isEnabled = doneButtonEnabled
                self.currentFileLabel.stringValue = title
                
                if indeterminate {
                    self.progressIndicator.isIndeterminate = true
                    self.progressIndicator.startAnimation(self)
                } else {
                    self.progressIndicator.isIndeterminate = false
                    self.progressIndicator.stopAnimation(self)
                    
                    self.progressIndicator.doubleValue = 100.0
                }
            
            case .working(let title, let details, let progress):
                self.doneButton.isEnabled = false
                self.currentFileLabel.stringValue = "\(title): \(details)"
                
                self.progressIndicator.isIndeterminate = false
                self.progressIndicator.stopAnimation(self)
                
                self.progressIndicator.doubleValue = progress
            
            case .undefined:
                assert(false, "CleaningViewController: Cannot update to state 'undefined'")
        }
    }
}

extension CleaningViewController: XcodeFilesDeleteDelegate {
    func deleteWillBegin(xcodeFiles: XcodeFiles) {
        self.state = .idle(title: "Initialization...", indeterminate: true, doneButtonEnabled: false)
    }
    
    func deleteInProgress(xcodeFiles: XcodeFiles, location: String, label: String, url: URL, current: Int, total: Int) {
        let progress = Double(current) / Double(total) * 100.0
        self.state = .working(title: location.capitalized, details: label, progress: progress)
    }
    
    func deleteDidFinish(xcodeFiles: XcodeFiles) {
        self.state = .idle(title: "Finished!", indeterminate: false, doneButtonEnabled: true)
    }
}
