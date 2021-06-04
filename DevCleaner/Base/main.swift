//
//  main.swift
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

import Cocoa

internal let log = Logger(name: "MainLog", level: .info, toFile: true)

// MARK: Helpers
private func commandLineDebugEnabled() -> Bool {
    #if DEBUG
    return Preferences.shared.envKeyPresent(key: "DCCmdLineDebug")
    #else
    return false
    #endif
}

private func isRunningFromCommandLine(args: [String]) -> Bool {
    let isTTY = isatty(STDIN_FILENO) // with this param true, we can always assune we run from command line
    
    // it seems that's enough, but maybe in the future we can also try to check parent PID,
    // to make sure. We also check for a special argument passed usually by Xcode & debugger to mark we run from Xcode and usually
    // want a full window, it's not a great way though

    #if DEBUG
    let isRunningFromXcode = args.contains("-NSDocumentRevisionsDebugMode")
    #else
    let isRunningFromXcode = false
    #endif
    
    return commandLineDebugEnabled() || (isTTY == 1 && !isRunningFromXcode)
}

private func cleanedCommandLineArguments(args: [String]) -> [String] {
    var resultArgs = args
    
    // we have to remove some Xcode stuff here
    if commandLineDebugEnabled() {
        if let index = resultArgs.firstIndex(of: "-NSDocumentRevisionsDebugMode") {
            resultArgs.remove(at: index)
            resultArgs.remove(at: index) // twice as there's "YES" afterwards
        }
    }
    
    return resultArgs
}

// MARK: App Start

// save app path to defaults
Preferences.shared.appFolder = Bundle.main.bundleURL

let cleanedArgs = cleanedCommandLineArguments(args: CommandLine.arguments)
if isRunningFromCommandLine(args: cleanedArgs) {
    log.consoleLogging = false // disable console logging to not interfere with console output, file log will still be available
    CmdLine.shared.start(args: cleanedArgs)
} else {
    let _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}
