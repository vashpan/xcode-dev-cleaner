#!/bin/bash

#  dev-cleaner.sh
#  DevCleaner
#
#  "dev-cleaner" command line tool wrapper script.
#
#  Copyright © 2019-2024 One Minute Games. All rights reserved.
#
#  DevCleaner is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  DevCleaner is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with DevCleaner.  If not, see <http://www.gnu.org/licenses/>.

# get app updated app path
DEV_CLEANER_PATH=$(defaults read com.oneminutegames.XcodeCleaner DCAppFolder)

# set a command line run env value
DEV_CLEANER_FROM_COMMAND_LINE=1

if [ -d $DEV_CLEANER_PATH ]; then
    "$DEV_CLEANER_PATH/Contents/MacOS/DevCleaner" "$@"
else
    echo "DevCleaner cannot be found, check if you haven't uninstalled it or moved. Path where it was expected: $DEV_CLEANER_PATH"
fi
