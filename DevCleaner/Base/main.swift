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
    // We have few ways of checking it, first is checking if our STDOUT is bound to some terminal
    // and second is checking for presence of env variable set in dev-cleaner.sh script. It helps
    // in cases where we want to run the script from headless environments where there's no TTY.
    //
    // Maybe there're better & more sure ways of handling/checking that, but I could't really found them.
    //
    
    let isTTY = isatty(STDIN_FILENO)
    let haveProperEnvValue = Preferences.shared.envKeyPresent(key: "DEV_CLEANER_FROM_COMMAND_LINE")

    let runningFromCommandLine = isTTY == 1 || haveProperEnvValue

    #if DEBUG
    let runningFromXcode = args.contains("-NSDocumentRevisionsDebugMode")
    #else
    let runningFromXcode = false
    #endif
    
    return commandLineDebugEnabled() || (runningFromCommandLine && !runningFromXcode)
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
