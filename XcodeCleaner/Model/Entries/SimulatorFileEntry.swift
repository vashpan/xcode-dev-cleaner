//
//  SimulatorFileEntry.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 27.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

public final class SimulatorFileEntry: XcodeFileEntry {
    public let system: String
    public let version: Version
    
    public init(system: String, version: Version, selected: Bool) {
        self.system = system
        self.version = version
        
        super.init(label: "\(self.system) \(self.version)", icon: .image(name: "Simulators/Simulator"), selected: selected)
    }
}
