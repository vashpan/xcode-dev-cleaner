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
    public let rootLocation: String
    
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
        let folderExists = FileManager.default.fileExists(atPath: location)
        
        // more checks, like folders structure
        var structureProper = true
        
        let foldersToCheck = ["Xcode", "CoreSimulator", "Shared/Documentation"]
        for folder in foldersToCheck {
            let nsStringLocation = location as NSString
            let folderPath = nsStringLocation.appendingPathComponent(folder)
            
            if !FileManager.default.fileExists(atPath: folderPath) {
                structureProper = false
                break
            }
        }
        
        return folderExists && structureProper
    }
}
