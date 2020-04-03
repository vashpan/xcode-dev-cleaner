//
//  ArgumentsParser.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 24/08/2019.
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

import Foundation

// If you ever want to publish this as a separate library (or part of some utils code)
// it will require some improvements:
//
// - support for "commands" in a separation of options
// - built-in parsing of values
// - shorthands
// - improved help printing, with better tabulation (check out "swift" command help output)

// MARK: Command line options
public protocol CommandLineOption {
    var name: String {get}
    var description: String {get}
    
    var enabled: Bool {get}
}

public struct OptionWithValue: CommandLineOption {
    public let name: String
    public let description: String

    public let possibleValues: [String]?
    public var value: String?
    
    public var enabled: Bool {
        return self.value != nil
    }
}

public struct Option: CommandLineOption {
    public let name: String
    public let description: String
    
    public internal(set) var enabled: Bool
}

// MARK: - Arguments parser
public class ArgumentsParser {
    // MARK: Types
    public enum Error: Swift.Error {
        case wrongArgument(name: String), noValue(optionName: String), insufficientArguments
    }
    
    // MARK: Properties
    private let description: String
    private var options: [CommandLineOption]
    
    // MARK: Initialization
    public init(description: String) {
        self.description = description
        self.options = []
    }
    
    // MARK: Adding arguments
    public func addOption(name: String, description: String) {
        let option = Option(name: name, description: description, enabled: false)
        self.options.append(option)
    }
    
    public func addOptionWithValue(name: String, description: String, possibleValues: [String]? = nil) {
        let option = OptionWithValue(name: name, description: description, possibleValues: possibleValues, value: nil)
        self.options.append(option)
    }
    
    // MARK: Parsing
    public func parse(using args: [String]) throws -> [CommandLineOption] {
        // we have options but non were given
        if self.options.count > 0 && args.count == 1 {
            throw Error.insufficientArguments
        } else if self.options.count == 0 {
            return [] // if no options then we can just return an empty array early on
        }
                
        var results = [CommandLineOption]()
        
        var i = 1 // ignore first one as its a name of program
        while i < args.count {
            let arg = args[i]
            
            var currentArgParsed = false
            for option in self.options {
                if arg == option.name && !results.contains(where: { $0.name == option.name }) {
                    // option with value
                    if var currentOptionWithValue = option as? OptionWithValue {
                        // find and parse value
                        let nextArgIndex = i + 1
                        if nextArgIndex < args.count {
                            currentOptionWithValue.value = args[nextArgIndex]
                            
                            i = nextArgIndex
                        } else {
                            throw Error.noValue(optionName: currentOptionWithValue.name)
                        }
                        
                        results.append(currentOptionWithValue)
                    }
                    // just option
                    else if var currentNewOption = option as? Option {
                        currentNewOption.enabled = true
                        results.append(currentNewOption)
                    }
                    
                    currentArgParsed = true
                    break
                }
            }
            
            if !currentArgParsed {
                throw Error.wrongArgument(name: arg)
            }
            
            i += 1
        }
        
        return results
    }
    
    // MARK: Utilities
    public func printHelp() {
        print("OVERVIEW: \(self.description)\n")
        print("USAGE: \(ProcessInfo.processInfo.processName + " <command> [options]")\n")
        print("OPTIONS:\n")
        
        for option in self.options {
            if let optionWithValue = option as? OptionWithValue {
                let valueString: String
                if let possibleValues = optionWithValue.possibleValues {
                    valueString = "<\(possibleValues.reduce("") { $0 + $1 + "," }.dropLast(1))>"
                } else {
                    valueString = "<value>"
                }
                
                print(" \(optionWithValue.name) \(valueString)")
                print("\t\(optionWithValue.description)")
            } else {
                print(" \(option.name)")
                print("\t\(option.description)")
            }
        }
    }
}
