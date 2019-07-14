//
//  XcodeFileEntry.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 10.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//
//  DevCleaner is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  DevCleaner is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with DevCleaner.  If not, see <http://www.gnu.org/licenses/>.

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
    
    public enum Selection {
        case on, off, mixed
    }
    
    public enum Icon {
        case path(url: URL)
        case image(name: String)
        case system(name: NSImage.Name)
    }
    
    // MARK: Properties
    public let icon: Icon?
    public let label: String
    public let extraInfo: String
    public let tooltipText: String
    public let tooltip: Bool
    
    public private(set) var selection: Selection
    public private(set) var size: Size
    public var selectedSize: Int64 {
        var result: Int64 = 0
        
        // sizes of children
        for item in self.items {
            result += item.selectedSize
        }
        
        // own size (only if selected and we have paths)
        if self.selection == .on && self.paths.count > 0 {
            result += self.size.numberOfBytes ?? 0
        }
        
        return result
    }
    
    public private(set) var paths: [URL]
    
    public private(set) weak var parent: XcodeFileEntry?
    public private(set) var items: [XcodeFileEntry]
    
    public var numberOfNonEmptyItems: Int {
        return self.items.filter { !$0.isEmpty }.count
    }
    
    public var isEmpty: Bool {
        return (self.items.count == 0 && self.paths.count == 0)
    }
    
    public var isSelected: Bool {
        return self.selection != .off
    }
    
    // MARK: Initialization
    public init(label: String, extraInfo: String = String(), tooltipText: String? = nil, icon: Icon? = nil, tooltip: Bool = false, selected: Bool) {
        self.icon = icon
        self.label = label
        self.extraInfo = extraInfo
        self.tooltipText = (tooltipText ?? "\(label) \(extraInfo)").trimmingCharacters(in: .whitespacesAndNewlines)
        self.tooltip = tooltip
        
        self.selection = selected ? .on : .off
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
        
        item.parent = self
        self.items.append(item)
    }
    
    public func addChildren(items: [XcodeFileEntry]) {
        // you can add path only if we have no children
        guard self.paths.count == 0 else {
            assertionFailure("❌ Cannot add children items to XcodeFileEntry if we already have paths!")
            return
        }
        
        for item in items {
            item.parent = self
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
    
    public func addPaths(paths: [URL]) {
        for path in paths {
            self.addPath(path: path)
        }
    }
    
    // MARK: Selection
    public func selectWithChildItems() {
        self.selection = .on
        for item in self.items {
            item.selectWithChildItems()
        }
    }
    
    public func deselectWithChildItems() {
        self.selection = .off
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
            if let dirSize = try? fileManager.allocatedSizeOfDirectory(atUrl: pathUrl) {
                result += dirSize
            } else if let fileSize = try? fileManager.allocatedSizeOfFile(at: pathUrl) {
                result += fileSize
            }
        }
        
        self.size = .value(result)
        return self.size
    }
    
    @discardableResult
    public func recalculateSelection() -> Selection {
        var result: Selection
        
        // calculate selection for child items
        for item in self.items {
            item.recalculateSelection()
        }
        
        // calculate own selection
        if self.numberOfNonEmptyItems > 0 {
            let selectedItems = self.items.reduce(0) { (result, item) -> Int in
                return result + (item.isSelected ? 1 : 0)
            }
            
            if selectedItems == self.numberOfNonEmptyItems {
                if self.items.filter( { $0.selection == .mixed } ).count > 0 {
                    result = .mixed
                } else {
                    result = .on
                }
            } else if selectedItems == 0 {
                result = .off
            } else {
                result = .mixed
            }
        } else {
            // with no items use current selection or deselect if its empty
            if self.isEmpty {
                result = .off
            } else {
                result = self.selection
            }
        }
        
        self.selection = result
        return result
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
