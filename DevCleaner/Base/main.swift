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

// for command line mode, we need a special first argument
// FIXME: Maybe find some better way to recognize that we start from command line?
if CommandLine.argc >= 2 && CommandLine.arguments.contains("--cmd-tool-mode") {
    CmdLineTool.start(args: Array(CommandLine.arguments.suffix(from: 2)))
} else {
    let _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}
