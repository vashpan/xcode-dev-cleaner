//
//  XcodeEntryCellView.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 14.04.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

final class XcodeEntryCellView: NSTableCellView {
    @IBOutlet weak var checkBox: NSButton!
    
    func setup(with xcodeEntry: XcodeFileEntry) {
        guard let textField = self.textField else {
            return
        }
        
        // checkbox
        self.checkBox.state = xcodeEntry.selected ? .on : .off
  
        // label
        textField.stringValue = xcodeEntry.label
        textField.sizeToFit()
    }
}
