//
//  Logger.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 20.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

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
