//
//  SizeCellView.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 14.04.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//
//  XcodeCleaner is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  XcodeCleaner is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with XcodeCleaner.  If not, see <http://www.gnu.org/licenses/>.

import Cocoa

final class SizeCellView: NSTableCellView {
    func setup(with xcodeEntry: XcodeFileEntry) {
        if let textField = self.textField, let sizeInBytes = xcodeEntry.size.numberOfBytes {
            textField.placeholderString = ByteCountFormatter.string(fromByteCount: sizeInBytes, countStyle: .file)
            textField.sizeToFit()
        }
    }
}
