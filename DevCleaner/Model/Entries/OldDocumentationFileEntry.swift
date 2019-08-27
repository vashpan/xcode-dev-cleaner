//
//  OldDocumentationFileEntry.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 14/07/2019.
//  Copyright © 2019 One Minute Games. All rights reserved.
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

public final class OldDocumentationFileEntry: XcodeFileEntry {
    public override var fullDescription: String {
        return ""
    }
    
    public init(selected: Bool) {
        super.init(label: "Old Documentation Downloads",
                   tooltipText: "Old offline documentations, not used anymore in modern Xcodes",
                   icon: .none,
                   tooltip: true,
                   selected: selected)
    }
}
