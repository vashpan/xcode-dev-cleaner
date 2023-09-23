//
//  CleaningViewController.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 29.04.2018.
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

import Cocoa

// MARK: Cleaning view controller delegate
internal protocol CleaningViewControllerDelegate: AnyObject {
    func cleaningDidFinish(_ vc: CleaningViewController)
}

// MARK: - Cleaning view controller
internal final class CleaningViewController: NSViewController {
    // MARK: Types
    internal enum State {
        case undefined
        
        case idle(title: String, progress: Double)
        case working(title: String, details: String, progress: Double)
    }
    
    // MARK: Properties & outlets
    @IBOutlet private weak var headerLabel: NSTextField!
    @IBOutlet private weak var currentFileLabel: NSTextField!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    
    internal weak var delegate: CleaningViewControllerDelegate?
    
    internal var state: State = .undefined {
        didSet {
            if self.isViewLoaded {
                self.update(state: self.state)
            }
        }
    }
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update first state we set
        self.update(state: self.state)
        
        // check if we are in dry run and mark it
        let dryRunText = Preferences.shared.dryRunEnabled ? "(Dry run) " : String()
        self.headerLabel.stringValue = "\(dryRunText)Cleaning Xcode cache files..."
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.styleMask.remove(.resizable)
    }
    
    // MARK: Updating state
    private func update(state: State) {
        switch state {
            case .idle(let title, let progress):
                self.currentFileLabel.stringValue = title
                
                self.progressIndicator.isIndeterminate = false
                self.progressIndicator.stopAnimation(self)
                
                self.progressIndicator.doubleValue = progress
            
            case .working(let title, let details, let progress):
                self.currentFileLabel.stringValue = "\(title): \(details)"
                
                self.progressIndicator.isIndeterminate = false
                self.progressIndicator.stopAnimation(self)
                
                self.progressIndicator.doubleValue = progress
            
            case .undefined:
                assert(false, "CleaningViewController: Cannot update to state 'undefined'")
        }
    }
    
    // MARK: Action
    @IBAction func dismissCleaningView(_ sender: Any) {
        self.dismiss(sender)
        
        self.delegate?.cleaningDidFinish(self)
    }
    
    @IBAction func stopCleaning(_ sender: Any) {
        self.dismiss(sender)
        
        self.delegate?.cleaningDidFinish(self)
    }
}

extension CleaningViewController: XcodeFilesDeleteDelegate {
    func deleteWillBegin(xcodeFiles: XcodeFiles) {
        DispatchQueue.main.async {
            self.state = .idle(title: "Initialization...", progress: 0.0)
        }
    }
    
    func deleteInProgress(xcodeFiles: XcodeFiles, location: String, label: String, url: URL?, current: Int, total: Int) {
        let progress = Double(current) / Double(total) * 100.0
        DispatchQueue.main.async {
            self.state = .working(title: location.capitalized, details: label, progress: progress)
        }
    }
    
    func deleteItemFailed(xcodeFiles: XcodeFiles, error: Error, location: String, label: String, url: URL?) {
        // prepare error message
        let message = """
        Following file couldn't be removed:\n\(location.capitalized): \(url?.path ?? "-")\n\n
        \(error.localizedDescription)
        """
        
        // show error message
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Failed to delete item"
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func deleteDidFinish(xcodeFiles: XcodeFiles) {
        DispatchQueue.main.async {
            self.state = .idle(title: "Finished!", progress: 100.0)
            
            // wait a little bit and then dismiss to avoid too abtrupt transition
            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 0.5) {
                self.dismiss(self)
                self.delegate?.cleaningDidFinish(self)
            }
        }
    }
}
