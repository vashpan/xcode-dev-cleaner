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
    public let name: String
    public var fileLogging: Bool {
        return self.logFileHandle != nil
    }
    public let logFilePath: URL?
    
    private let logFileHandle: FileHandle?
    
    // MARK: Initialization
    public init(name: String, level: Level = .error, toFile: Bool = false) {
        self.name = name
        self.level = level
        
        if toFile {
            // create logfile path
            let bundleId = Bundle.main.bundleIdentifier ?? "UnknownApp"
            let logFileName = "\(bundleId)-\(self.name)-LogFile-latest.log"
            let documentsFolder = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            // create if needed & open log file to write
            if let logFilePath = documentsFolder?.appendingPathComponent(logFileName) {
                do {
                    FileManager.default.createFile(atPath: logFilePath.path, contents: nil, attributes: nil)
                    self.logFileHandle = try FileHandle(forWritingTo: logFilePath)
                    self.logFilePath = logFilePath
                } catch(let error) {
                    self.logFileHandle = nil
                    self.logFilePath = nil
                    NSLog("❌ Can't create log file: \(logFilePath.path). Error: \(error)")
                }
            } else {
                self.logFileHandle = nil
                self.logFilePath = nil
            }
        } else {
            self.logFileHandle = nil
            self.logFilePath = nil
        }
    }
    
    deinit {
        self.logFileHandle?.closeFile()
    }
    
    // MARK: Helpers
    private func writeLog(text: String) {
        NSLog(text)
        
        if let fileHandle = self.logFileHandle {
            let textToLogToFile = text + "\n" // add new line for each entry
            if let logData = textToLogToFile.data(using: .utf8) {
                fileHandle.write(logData)
                fileHandle.synchronizeFile()
            }
        }
    }
    
    // MARK: Log methods
    public func info(_ message: String) {
        switch self.level {
            case .info:
                self.writeLog(text: "❕ \(message)")
            default:
                return
        }
    }
    
    public func warning(_ message: String) {
        switch self.level {
            case .info, .warning:
                self.writeLog(text: "⚠️ \(message)")
            default:
                return
        }
    }
    
    public func error(_ message: String) {
        switch self.level {
            case .info, .warning, .error:
                self.writeLog(text: "❌ \(message)")
        }
    }
}
