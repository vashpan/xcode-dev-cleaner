//
//  SimulatorFileEntry.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 27.03.2018.
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

public final class SimulatorFileEntry: XcodeFileEntry {
    // MARK: Properties
    public let system: String
    public let version: Version
    
    // MARK: Initialization
    public init(system: String, version: Version, selected: Bool) {
        self.system = system
        self.version = version
        
        super.init(label: "\(self.system) \(self.version)", icon: .image(name: "Simulators/Simulator"), selected: selected)
    }
}
