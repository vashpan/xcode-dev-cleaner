//
//  XcodeFiles.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 10.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

final public class XcodeFiles {
    // MARK: Properties
    private let rootLocation: String
    
    public static var defaultXcodeCachesLocation: String? {
        guard let librariesUrl = try? FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        
        return librariesUrl.appendingPathComponent("Developer", isDirectory: true).path
    }
    
    // MARK: Initialization
    public init?(xcodeDevLocation: String) {
        guard XcodeFiles.checkIfLocationIsValid(location: xcodeDevLocation) else {
            return nil
        }
        
        self.rootLocation = xcodeDevLocation
    }
    
    // MARK: Helpers
    private static func checkIfLocationIsValid(location: String) -> Bool {
        // check if folder exists
        return FileManager.default.fileExists(atPath: location)
        
        // FIXME: More checks, like folders structure
    }
}
