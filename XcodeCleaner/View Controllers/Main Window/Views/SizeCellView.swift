//
//  SizeCellView.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 14.04.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

final class SizeCellView: NSTableCellView {
    func setup(with xcodeEntry: XcodeFileEntry) {
        if let textField = self.textField, let sizeInBytes = xcodeEntry.size.numberOfBytes {
            textField.placeholderString = ByteCountFormatter.string(fromByteCount: sizeInBytes, countStyle: .file)
            textField.sizeToFit()
        }
    }
}
