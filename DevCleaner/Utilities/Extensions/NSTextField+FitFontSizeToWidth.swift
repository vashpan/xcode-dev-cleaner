//
//  NSTextField+FitFontSizeToWidth.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 15.07.2018.
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

import Foundation
import AppKit

public extension NSTextField {
    func adjustFontSizeToFitWidth() {
        guard let currentFont = self.font else {
            return
        }

        // find a font size that will fit in our text field
        let attributedString = NSMutableAttributedString(attributedString: self.attributedStringValue)
        var fontSize = currentFont.pointSize
        var stringSize = attributedString.size()
        
        while ceil(stringSize.width) >= self.frame.size.width {
            if fontSize <= 1.0 { // we can't go any further
                break
            }
            
            let newFontSize = fontSize - 1.5
            if let newFont = NSFont(descriptor: currentFont.fontDescriptor, size: newFontSize) {
                attributedString.addAttribute(.font, value: newFont, range: NSMakeRange(0, attributedString.length))
                
                fontSize = newFontSize
                stringSize = attributedString.size()
            } else {
                continue
            }
        }
        
        self.attributedStringValue = attributedString
        self.needsDisplay = true
    }
}
