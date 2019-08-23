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

// MARK: Helpers
private func isRunningFromCommandLine() -> Bool {
    let isTTY = isatty(STDIN_FILENO) // with this param true, we can always assune we run from command line
    
    // it seems that's enough, but maybe in the future we can also try to check parent PID,
    // to make sure 
    
    return isTTY == 1
}

// MARK: App Start

if isRunningFromCommandLine() {
    CmdLineTool.start(args: CommandLine.arguments)
} else {
    let _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}
