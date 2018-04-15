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
    @IBOutlet weak var checkBox: NSButton!
    
    weak var delegate: XcodeEntryCellViewDelegate? = nil
    
    private weak var entry: XcodeFileEntry?
    
    // MARK: Setup
    func setup(with xcodeEntry: XcodeFileEntry, delegate: XcodeEntryCellViewDelegate) {
        guard let textField = self.textField else {
            return
        }
        
        // delegate
        self.delegate = delegate
        
        // checkbox
        self.checkBox.state = xcodeEntry.selected ? .on : .off
  
        // label
        textField.stringValue = xcodeEntry.label
        textField.sizeToFit()
        
        self.entry = xcodeEntry
    }
    
    // MARK: Actions
    @IBAction func checkBoxSwitched(_ sender: NSButton) {
        self.delegate?.xcodeEntryCellSelectedChanged(self, state: sender.state, xcodeEntry: self.entry)
    }
}
