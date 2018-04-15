//
//  XcodeFileEntry.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 10.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation
import Cocoa

open class XcodeFileEntry: NSObject {
    // MARK: Types
    public enum Size {
        case unknown, value(Int64)
        
        public var numberOfBytes: Int64? {
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
    public var selected: Bool
    
    public private(set) var size: Size
    public var selectedSize: Int64 {
        var result: Int64 = 0
        
        // sizes of children
        for item in self.items {
            result += item.selectedSize
        }
        
        // own size (only if selected and we have paths)
        if self.selected && self.paths.count > 0 {
            result += self.size.numberOfBytes ?? 0
        }
        
        return result
    }
    
    public private(set) var paths: [URL]
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
        // you can add path only if we have no children
        guard self.paths.count == 0 else {
            assertionFailure("❌ Cannot add child item to XcodeFileEntry if we already have paths!")
            return
        }
        
        self.items.append(item)
    }
    
    public func addChildren(items: [XcodeFileEntry]) {
        // you can add path only if we have no children
        guard self.paths.count == 0 else {
            assertionFailure("❌ Cannot add children items to XcodeFileEntry if we already have paths!")
            return
        }
        
        self.items.append(contentsOf: items)
    }
    
    public func removeAllChildren() {
        self.items.removeAll()
    }
    
    // MARK: Manage paths
    public func addPath(path: URL) {
        // you can add path only if we have no children
        guard self.items.count == 0 else {
            assertionFailure("❌ Cannot add paths to XcodeFileEntry if we already have children!")
            return
        }
        
        self.paths.append(path)
    }
    
    // MARK: Selection
    public func selectWithChildItems() {
        self.selected = true
        for item in self.items {
            item.selectWithChildItems()
        }
    }
    
    public func deselectWithChildItems() {
        self.selected = false
        for item in self.items {
            item.deselectWithChildItems()
        }
    }
    
    // MARK: Operations
    @discardableResult
    public func recalculateSize() -> Size? {
        var result: Int64 = 0
        
        // calculate sizes of children
        for item in self.items {
            if let size = item.recalculateSize(), let sizeInBytes = size.numberOfBytes {
                result += sizeInBytes
            }
        }
        
        // calculate own size
        let fileManager = FileManager.default
        for pathUrl in self.paths {
            if let pathSize = try? fileManager.allocatedSizeOfDirectory(atUrl: pathUrl) {
                result += pathSize
            }
        }
        
        self.size = .value(result)
        return self.size
    }
    
    public func debugRepresentation(level: Int = 1) -> String {
        var result = String()
        
        // print own
        result += String(repeating: "\t", count: level)
        result += " \(self.label)"
        if let sizeInBytes = self.size.numberOfBytes {
            result += ": \(ByteCountFormatter.string(fromByteCount: sizeInBytes, countStyle: .file))"
        }
        result += "\n"
        
        // print children
        for item in self.items {
            result += item.debugRepresentation(level: level + 1)
        }
        
        return result
    }
}
