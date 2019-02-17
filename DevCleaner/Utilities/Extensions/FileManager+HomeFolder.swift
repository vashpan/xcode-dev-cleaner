//
//  URL+HomeFolder.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 18/02/2019.
//  Copyright © 2019 One Minute Games. All rights reserved.
//

import Foundation

public extension FileManager {
    public var realHomeDirectoryForCurrentUser: URL {
        let pw = getpwuid(getuid())
        let home = pw?.pointee.pw_dir
        let homePath = FileManager.default.string(withFileSystemRepresentation: home!, length: Int(strlen(home)))
        
        return URL(fileURLWithPath: homePath, isDirectory: true)
    }
}
