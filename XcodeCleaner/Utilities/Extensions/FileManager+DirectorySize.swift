//
//  FileManager+DirectorySize.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 18.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//
//  XcodeCleaner is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  XcodeCleaner is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with XcodeCleaner.  If not, see <http://www.gnu.org/licenses/>.

//
//  Original code:
//
//  Created by Nikolai Ruhe on 2016-02-10.
//  Copyright (c) 2016 Nikolai Ruhe. All rights reserved.
//
//  https://gist.github.com/NikolaiRuhe/eeb135d20c84a7097516
//  https://gist.github.com/blender/a75f589e6bd86aa2121618155cbdf827
//

import Foundation

public extension FileManager {
    /// This method calculates the accumulated size of a directory on the volume in bytes.
    ///
    /// As there's no simple way to get this information from the file system it has to crawl the entire hierarchy,
    /// accumulating the overall sum on the way. The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    public func allocatedSizeOfDirectory(atUrl url: URL) throws -> Int64 {
        
        // We'll sum up content size here:
        var accumulatedSize: Int64 = 0
        
        // prefetching some properties during traversal will speed up things a bit.
        let prefetchedProperties: [URLResourceKey] = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey
        ]
        
        // The error handler simply signals errors to outside code.
        var errorDidOccur: Error?
        let errorHandler: (URL, Error) -> Bool = { _, error in
            errorDidOccur = error
            return false
        }
        
        
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: url,
                                         includingPropertiesForKeys: prefetchedProperties,
                                         options: FileManager.DirectoryEnumerationOptions.init(rawValue: 0),
                                         errorHandler: errorHandler)
        
        // Start the traversal:
        while let contentURL = (enumerator?.nextObject() as? URL)  {
            
            // Bail out on errors from the errorHandler.
            if let error = errorDidOccur { throw error }
            
            // Get the type of this item, making sure we only sum up sizes of regular files.
            let resourceValues = try contentURL.resourceValues(forKeys: [.isRegularFileKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
            
            guard resourceValues.isRegularFile ?? false else {
                continue
            }
            
            // To get the file's size we first try the most comprehensive value in terms of what the file may use on disk.
            // This includes metadata, compression (on file system level) and block size.
            var fileSize = resourceValues.totalFileAllocatedSize
            
            // In case the value is unavailable we use the fallback value (excluding meta data and compression)
            // This value should always be available.
            fileSize = fileSize ?? resourceValues.fileAllocatedSize
            
            // We're good, add up the value.
            accumulatedSize += Int64(fileSize ?? 0)
        }
        
        // Bail out on errors from the errorHandler.
        if let error = errorDidOccur { throw error }
        
        // We finally got it.
        return accumulatedSize
    }
}
