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
    
    // MARK: Functions
    public func addPath(path: String) {
        self.paths.append(path)
    }
    
    public func addChild(item: XcodeFileEntry) {
        self.items.append(item)
    }
    
    public func recalculateSize(completion: (Error?, Size) -> Void) {
        var result: UInt64 = 0
        
        // calculate sizes of children
        for item in self.items {
            item.recalculateSize() { (error, resultSize) in
                if let sizeInBytes = resultSize.numberOfBytes {
                    result += sizeInBytes
                }
            }
        }
        
        // calculate own size
        let fileManager = FileManager.default
        for path in self.paths {
            if let pathAttributes = try? fileManager.attributesOfItem(atPath: path) {
                if let pathSize = pathAttributes[.size] as? NSNumber {
                    result += pathSize.uint64Value
                }
            }
        }
        
        self.size = .value(result)
        completion(nil, self.size)
    }
}
