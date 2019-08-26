//
//  CmdLineTool.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 20/08/2019.
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

final class CmdLineTool {
    // MARK: Types
    private enum Error: Swift.Error {
        case wrongOption(option: String), conflictingOptions
    }
    
    private enum Mode {
        case clean, info, help
    }
    
    // MARK: Helpers
    private static func printAppInfo() {
        guard let bundleInfoDictionary = Bundle.main.infoDictionary else {
            fatalError("CmdLineTool: No Info.plist in main app bundle!?")
        }
        
        guard let appVersion = bundleInfoDictionary["CFBundleShortVersionString"] as? String else {
            fatalError("CmdLineTool: Can't get app version from main bundle!")
        }
        
        guard let appBuildNumber = bundleInfoDictionary["CFBundleVersion"] as? String else {
            fatalError("CmdLineTool: Can't get app build number from main bundle!")
        }
        
        print("DevCleaner \(appVersion) (\(appBuildNumber))")
        print()
    }
    
    private static func printErrorAndExit(errorMessage: String) {
        print("Error: \(errorMessage)")
        print()
        
        if let logFilePath = log.logFilePath {
            print("You can check full log here: \(logFilePath.path)")
            print()
        }
        
        exit(1)
    }
    
    private static func printHelpAndExit(using argsParser: ArgumentsParser) {
        argsParser.printHelp()
        exit(0)
    }
    
    private static func printAvailableEntriesToClean(entries: [XcodeFiles.Location: XcodeFileEntry]) {
        print("Detailed informations to be done!")
    }
    
    private static func cleanOptionsToXcodeFileLocation(_ value: String) throws -> [XcodeFiles.Location] {
        // do we have all listed here?
        if value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "all" {
            return XcodeFiles.Location.allCases
        }
        // else just split it and parse each individual
        else {
            let splittedOptions = value.split(separator: ",")
            let result: [XcodeFiles.Location] = try splittedOptions.map {
                let trimmedOption = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                switch trimmedOption {
                    case "device-support":
                        return .deviceSupport
                    case "archives":
                        return .archives
                    case "derived-data":
                        return .derivedData
                    case "old-logs":
                        return .logs
                    case "old-documentation":
                        return .oldDocumentation
                    default:
                        throw Error.wrongOption(option: trimmedOption)
                }
            }
            
            return result
        }
    }
    
    // MARK: Start command line tool
    static func start(args: [String]) {
        printAppInfo()
        
        let argsParser = ArgumentsParser(description: "Reclaims storage that Xcode stores in caches and old files")
        argsParser.addOption(name: "info", description: "Show all items available to clean.")
        argsParser.addOptionWithValue(name: "clean",
                                      description: "Perform cleaning of given items. Available options: all,device-support,archives,derived-data,old-logs,old-documentation. If you want to clean all, pass \"all\"",
                                      possibleValues: ["all","device-support","archives","derived-data","old-logs","old-documentation"])
        argsParser.addOption(name: "--help", description: "Prints this message")
        
        do {
            let options = try argsParser.parse(using: args)
            
            // if we have too many options that's wrong
            if options.count > 1 {
                throw Error.conflictingOptions
            }
            
            // check mode from first option
            let mode: Mode
            if let firstOption = options.first {
                switch firstOption.name {
                    case "info":
                        mode = .info
                    case "clean":
                        mode = .clean
                    case "--help":
                        mode = .help
                    default:
                        throw ArgumentsParser.Error.wrongArgument(name: firstOption.name)
                }
            } else {
                throw ArgumentsParser.Error.insufficientArguments
            }
            
            // check options if we want to clean
            let locations: [XcodeFiles.Location]
            if mode == .clean {
                if let cleanOption = options.first as? OptionWithValue, let cleanOptionValue = cleanOption.value {
                    locations = try cleanOptionsToXcodeFileLocation(cleanOptionValue)
                } else {
                    throw ArgumentsParser.Error.noValue(optionName: "clean")
                }
            } else {
                locations = XcodeFiles.Location.allCases // in case of an info, we justs check everything
            }
            
            // start or show help
            if mode == .help {
                printHelpAndExit(using: argsParser)
            } else {
                self.start(mode: mode, locations: locations)
            }
        } catch(ArgumentsParser.Error.insufficientArguments) {
            printHelpAndExit(using: argsParser)
        } catch(ArgumentsParser.Error.noValue(let optionName)) {
            printErrorAndExit(errorMessage: "Expected value for option: \(optionName)")
        } catch(ArgumentsParser.Error.wrongArgument(let name)) {
            printErrorAndExit(errorMessage: "Unrecognized argument: \(name)")
        } catch(Error.wrongOption(let option)) {
            printErrorAndExit(errorMessage: "Wrong value for \"clean\": \(option)")
        } catch(Error.conflictingOptions) {
            printHelpAndExit(using: argsParser)
        } catch {
            printHelpAndExit(using: argsParser)
        }
    }
    
    private static func start(mode: Mode, locations: [XcodeFiles.Location]) {
        guard XcodeFiles.isXcodeIsInstalled() else {
            printErrorAndExit(errorMessage: "Xcode installation cannot be found! Check if you have Xcode installed.")
            return
        }
        
        guard let xcodeFiles = XcodeFiles(developerFolder: Files.userDeveloperFolder, customDerivedDataFolder: Files.customDerivedDataFolder, customArchivesFolder: Files.customArchivesFolder) else {
            printErrorAndExit(errorMessage: "Cannot locate Xcode cache files, or can't get access to ~/Library/Developer folder.\nCheck if you have Xcode installed and some projects built. Also, in the next run check if you selected proper folder.")
            return
        }
        
        // scan given locations
        print("Scanning...")
        xcodeFiles.cleanAllEntries()
        xcodeFiles.scanFiles(in: locations)
        let scannedEntries = xcodeFiles.locations
        let totalSize = ByteCountFormatter.string(fromByteCount: xcodeFiles.totalSize, countStyle: .file)
        
        switch mode {
            case .clean:
                print("Clean to be done!")
            case .info:
                printAvailableEntriesToClean(entries: scannedEntries)
                print("Total size available to clean: \(totalSize)")
            default:
                fatalError("Can't start with mode different than \"info\" or \"clean\"")
        }
    }
}
