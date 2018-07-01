//
//  Logger.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 20.03.2018.
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

public class Logger {
    // MARK: Types
    public enum Level {
        case info, warning, error
    }
    
    // MARK: Properties
    public let level: Level
    
    // MARK: Initialization
    public init(level: Level = .error) {
        self.level = level
    }
    
    // MARK: Log methods
    public func info(_ message: String) {
        switch self.level {
            case .info:
                NSLog("❕ \(message)")
            default:
                return
        }
    }
    
    public func warning(_ message: String) {
        switch self.level {
            case .info, .warning:
                NSLog("⚠️ \(message)")
            default:
                return
        }
    }
    
    public func error(_ message: String) {
        switch self.level {
            case .info, .warning, .error:
                NSLog("❌ \(message)")
        }
    }
}
