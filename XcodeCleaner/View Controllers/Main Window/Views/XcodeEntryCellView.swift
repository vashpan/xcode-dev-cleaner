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
        
        // icon
        self.imageView?.image = self.iconForEntry(xcodeEntry)
        
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
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.checkBox.isEnabled = true
        self.checkBox.state = .off
        
        self.imageView?.isEnabled = true
        self.textField?.isEnabled = true
    }
    
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
    
    private func iconForEntry(_ xcodeEntry: XcodeFileEntry) -> NSImage? {
        let result: NSImage?
        
        if let entryIcon = xcodeEntry.icon {
            switch entryIcon {
                case .image(let name):
                    result = NSImage(imageLiteralResourceName: name)
                case .system(let name):
                    result = NSImage(named: name)
            }
        } else {
            result = nil
        }
        
        return result
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
