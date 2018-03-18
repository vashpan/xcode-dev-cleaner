//
//  XcodeFileEntry.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 10.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation
import Cocoa

final public class XcodeFileEntry: NSObject {
    // MARK: Types
    public enum Size {
        case unknown, value(UInt64)
        
        public var numberOfBytes: UInt64? {
            switch self {
                case .value(let bytes):
                    return bytes
                default:
                    return nil
            }
        }
    }
    
    // MARK: Properties
    public let label: String
    public private(set) var size: Size
    public private(set) var selected: Bool
    
    public private(set) var paths: [String]
    public private(set) var items: [XcodeFileEntry]
    
    // MARK: Initialization
    public init(label: String, selected: Bool = true) {
        self.label = label
        self.selected = selected
        self.size = .unknown
        
        self.paths = []
        self.items = []
        
        super.init()
    }
    
    // MARK: Manage children
    public func addChild(item: XcodeFileEntry) {
        self.items.append(item)
    }
    
    public func addChildren(items: [XcodeFileEntry]) {
        self.items.append(contentsOf: items)
    }
    
    // MARK: Manage paths
    public func addPath(path: String) {
        self.paths.append(path)
    }
    
    // MARK: Operations
    @discardableResult
    public func recalculateSize() -> Size? {
        var result: UInt64 = 0
        
        // calculate sizes of children
        for item in self.items {
            if let size = item.recalculateSize(), let sizeInBytes = size.numberOfBytes {
                result += sizeInBytes
            }
        }
        
        // calculate own size
        let fileManager = FileManager.default
        for path in self.paths {
            let pathUrl = URL(fileURLWithPath: path)
            if let pathSize = try? fileManager.allocatedSizeOfDirectory(atUrl: pathUrl) {
                result += pathSize
            }
        }
        
        self.size = .value(result)
        return self.size
    }
    
    public func debugRepresentation(level: Int = 1) -> String {
        func bytes2mb(bytes: UInt64) -> Double {
            return Double(bytes) / 1024.0 / 1024.0
        }
        
        var result = String()
        
        // print own
        result += String(repeating: "\t", count: level)
        result += " \(self.label)"
        if let sizeInBytes = self.size.numberOfBytes {
            result += ": \(bytes2mb(bytes: sizeInBytes))MB"
        }
        result += "\n"
        
        // print children
        for item in self.items {
            result += item.debugRepresentation(level: level + 1)
        }
        
        return result
    }
}
