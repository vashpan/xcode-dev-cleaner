//
//  Stack.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 30.04.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

public struct Stack<T> {
    // MARK: Properties
    private var array = [T]()
    
    public var top: T? {
        return self.array.last
    }
    
    public var count: Int {
        return self.array.count
    }
    
    public var isEmpty: Bool {
        return self.count == 0
    }
    
    // MARK: Manipulate stack
    public mutating func push(_ e: T) {
        self.array.append(e)
    }
    
    @discardableResult
    public mutating func pop() -> T? {
        return self.array.popLast()
    }
}

extension Stack: CustomStringConvertible {
    public var description: String {
        let contents = self.array.map { "\($0)" }.reversed().joined(separator: ", ")
        
        return "[" + contents + "]"
    }
}
