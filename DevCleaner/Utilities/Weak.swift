//
//  Weak.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 03/10/2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

public class Weak<T: AnyObject>: Equatable {
    public private(set) weak var value: T?
    
    init(value: T?) {
        self.value = value
    }
    
    public static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        return lhs.value === rhs.value
    }
}
