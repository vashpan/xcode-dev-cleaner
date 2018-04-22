//
//  DerivedDataFileEntry.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 27.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

public final class DerivedDataFileEntry: XcodeFileEntry {
    public let projectName: String
    public let pathUrl: URL
    
    public init(projectName: String, pathUrl: URL, selected: Bool) {
        self.projectName = projectName
        self.pathUrl = pathUrl
        
        super.init(label: "\(self.projectName) (\(self.pathUrl.path))", selected: selected)
    }
}
