//
//  Profiler.swift
//  DevCleaner
//
//  Created by Konrad Kolakowski on 04/08/2019.
//  Copyright © 2019 One Minute Games. All rights reserved.
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

import os
import Foundation
import QuartzCore

public final class Profiler {
    private typealias ProfilerEntry = (name: StaticString, description: String, usingSignpost: Bool, start: CFTimeInterval)
    private static var starts = [ProfilerEntry]()
    
    private static let signpostLog: OSLog = {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            fatalError("Profiler: No bundleId defined in main bundle Infp.plist file?")
        }
        
        return OSLog(subsystem: bundleId + ".Profiler", category: .pointsOfInterest)
    }()
    
    public static func tick(name: StaticString = StaticString(), description: String = String(), useSignpost: Bool = false) {
        let tickTime = CACurrentMediaTime()
        let entry = (name: name, description: description, usingSignpost: useSignpost, start: tickTime)
        
        if useSignpost {
            os_signpost(.begin, dso: #dsohandle, log: Profiler.signpostLog, name: name, "%@", description as NSString)
        }
        
        self.starts.append(entry)
    }
    
    @discardableResult
    public static func tock(noLog silent: Bool = false) -> CFTimeInterval {
        let tockTime = CACurrentMediaTime() // get time here to avoid any influence of "tock" function logic
        var time = CFTimeInterval(0.0)
        
        if let lastEntry = self.starts.popLast() {
            time = tockTime - lastEntry.start
            
            if !silent {
                if lastEntry.usingSignpost {
                    if #available(iOS 12.0, *) {
                        os_signpost(.end, dso: #dsohandle, log: Profiler.signpostLog, name: lastEntry.name)
                    }
                }
                
                let number = self.starts.count
                let finalMessage: String
                
                if !lastEntry.name.description.isEmpty && !lastEntry.description.isEmpty {
                    finalMessage = "[Profile: \(number)][\(lastEntry.name) - \(lastEntry.description)]"
                } else if !lastEntry.name.description.isEmpty {
                    finalMessage = "[Profile: \(number)][\(lastEntry.name)]"
                } else {
                    finalMessage = "[Profile: \(number)]"
                }
                
                print(String(format: "\(finalMessage): %.f ms", time * 1000.0))
            }
        } else {
            print("Cannot stop profiling that haven't started yet!")
        }
        
        return time
    }
}
