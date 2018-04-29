//
//  ArchiveFileEntry.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 27.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

public final class ArchiveFileEntry: XcodeFileEntry {
    // MARK: Properties
    public let projectName: String
    public let bundleName: String
    public let version: Version
    public let build: String
    
    // MARK: Initialization
    public init(projectName: String, bundleName: String, version: Version, build: String, location: URL, icon: Icon? = nil, selected: Bool) {
        self.projectName = projectName
        self.bundleName = bundleName
        self.version = version
        self.build = build
        
        super.init(label: "\(self.version.description) \(self.build)", icon: icon, selected: selected)
        
        self.addPath(path: location)
    }
}
