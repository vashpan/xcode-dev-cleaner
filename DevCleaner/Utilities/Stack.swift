//
//  Stack.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 30.04.2018.
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
