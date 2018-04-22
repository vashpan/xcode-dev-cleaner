//
//  XcodeEntryCellView.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 14.04.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

// MARK: Xcode Entry Cell View Delegate
protocol XcodeEntryCellViewDelegate: class {
    func xcodeEntryCellSelectedChanged(_ cell: XcodeEntryCellView, state: NSControl.StateValue, xcodeEntry: XcodeFileEntry?)
}

// MARK: Xcode Entry Cell View
final class XcodeEntryCellView: NSTableCellView {
    // MARK: Properties & outlets
    @IBOutlet private weak var checkBox: NSButton!
    
    internal weak var delegate: XcodeEntryCellViewDelegate? = nil
    
    private weak var entry: XcodeFileEntry?
    
    // MARK: Setup
    internal func setup(with xcodeEntry: XcodeFileEntry, delegate: XcodeEntryCellViewDelegate) {
        guard let textField = self.textField else {
            return
        }
        
        // delegate
        self.delegate = delegate
        
        // checkbox
        self.checkBox.state = self.entrySelectionToControlState(xcodeEntry.selection)
        
        // label
        textField.stringValue = xcodeEntry.label
        textField.sizeToFit()
        
        // disable if no children and path
        if xcodeEntry.isEmpty {
            self.checkBox.isEnabled = false
            self.checkBox.state = .off
            
            self.imageView?.isEnabled = false
            self.textField?.isEnabled = false
        }
        
        self.entry = xcodeEntry
    }
    
    // MARK: Helpers
    private func entrySelectionToControlState(_ entrySelection: XcodeFileEntry.Selection) -> NSControl.StateValue {
        switch entrySelection {
        case .on:
            return .on
        case .off:
            return .off
        case .mixed:
            return .mixed
        }
    }
    
    // MARK: Actions
    @IBAction func checkBoxSwitched(_ sender: NSButton) {
        // when we click, disallow mixed state
        if sender.state == .mixed {
            sender.setNextState()
        }
        
        self.delegate?.xcodeEntryCellSelectedChanged(self, state: sender.state, xcodeEntry: self.entry)
    }
}
