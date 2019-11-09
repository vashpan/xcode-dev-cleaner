//
//  FileManager+DateProperties.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 09/11/2019.
//  Copyright © 2019 One Minute Games. All rights reserved.
//

import Foundation

extension FileManager {
    func dateModified(for url: URL) -> Date {
        guard let attrs = try? self.attributesOfItem(atPath: url.path) else {
            return Date.distantPast
        }
        
        guard let result = attrs[.modificationDate] as? Date else {
            return Date.distantPast
        }
        
        return result
    }
    
    func dateCreated(for url: URL) -> Date {
        guard let attrs = try? self.attributesOfItem(atPath: url.path) else {
            return Date.distantPast
        }
        
        guard let result = attrs[.creationDate] as? Date else {
            return Date.distantPast
        }
        
        return result
    }
}
