# DevCleaner

![Main Window Screenshot](https://github.com/vashpan/xcode-cleaner/raw/master/Documentation/Main%20Window%20Screenshot.png)

*Currently tested with macOS 10.15 and Xcode 11. Should support Xcode 12*

Available on the [Mac App Store](https://itunes.apple.com/app/devcleaner/id1388020431)

If you want to reclaim tens of gigabytes of your storage used for various Xcode caches - this tool is for you!

Xcode could store tens of gigabytes in `~/Developer` folder. Most of those cached files & symbols is not reclaimed over time
and could consume a large amount of your storage, which is especially important if you have relatively small SSD drive.

DevCleaner gives you an easy way to inspect auto-generated files and clean them if necessary. It could also remind you about 
scan after a while.

Please note that **this application is relying on internal folder structures and undocumented features**. It could stop working with
newer versions of Xcode! I tried to make sure this application is safe, but if you want to be sure, please **make backup before use it**.

## What DevCleaner could actually clean?

### Device Support

It consumes the largest part of the Xcode caches. Everytime you connect a device with the new iOS/watchOS/tvOS, its symbols must be downloaded 
to your computer, for efficient debugging. It consumes around 2-5GB per version. Even smallest updates requires new set of symbols. 

It could accumulate to hold tens of gigabytes of data.

This section is selected by default, with exception of the latest version of each system.

### Archives

When we create build for distrubution or export, a new archive is created. For each version it contains a build, debug symbols and 
other informations. Usually we need those archived items for crashes symbolications for example, but for sure we don't need all of them.
Xcode Cleaner allows to quickly inspect the archives and delete older ones or builds that are not on store.

### Derived Data

This is the major "cache" part of Xcode files, where autocompletion data, logs, debug builds, intermediate products and other stuff lives.
The point is that it could be regenerated if necessary. Also some older projects could be removed completely because its rather unusual that 
we would use them again.

### Old Simulator & Device Logs

Old device logs & crashes databases, only most recent ones are needed. It seems that new versions of Xcodes migrates old logs database, but keeping older ones on disk.

### Old Documentation Downloads

Old Xcodes had ability to download documentation to browse offline, it could've been many gigabytes. Although newer Xcodes has online documentation browser, 
those old documentations may be still on your drive if you're an old Xcode user. 

## Contact

If you enjoy this application, consider support me by making a tip in the app, or by downloading/buying some of my games from the AppStore 😎

Twitter: [@vashpan](https://twitter.com/vashpan), [@oneminutegames](https://twitter.com/OneMinuteGames)

Website: http://www.one-minute-games.com

## Contribution

This application is my first macOS app, so feel free to give me some feedback or pull requests! If there's some new feature to support, maybe some caches I missed, let me know as well in issues.

Application is licensed using GPL3. You may freely modify, download, redistribute and use this application from this source code, but only me, as copyright holder can submit it to the Mac App Store.

Copyright © 2018-2022 One Minute Games Konrad Kołakowski.
