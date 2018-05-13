# Xcode Cleaner

![Main Window Screenshot](https://github.com/vashpan/xcode-cleaner/raw/master/Documentation/Main%20Window%20Screenshot.png)

*Currently tested with macOS 10.13 and Xcode 9.x*

If you want to reclaim tens of gigabytes of your storage used for various Xcode caches - this tool is for you!

Xcode could store tens of gigabytes in `~/Developer` folder. Most of those cached files & symbols is not reclaimed over time
and could consume a large amount of your storage, which is especially important if you have relatively small SSD drive.

Xcode Cleaner gives you an easy way to inspect auto-generated files and clean them if necessary. It could also remind you about 
scan after a while.

Please note that **this application is relying on internal folder structures and undocumented features**. It could stop working with
newer versions of Xcode! I tried to make sure this application is safe, but if you want to be sure, please **make backup before use it**.

## What Xcode Cleaner could actually clean?

<insert some screenshot here>

### Device Support

It consumes the largest part of the Xcode caches. Everytime you connect a device with the new iOS/watchOS/tvOS, its symbols must be downloaded 
to your computer, for efficient debugging. It consumes around 2GB per version. Even smallest updates requires new set of symbols. 

It could accumulate to hold tens of gigabytes of data.

This section is selected by default, with exception of the latest versions.

### Unused Simulators

Sometime we need older simulators for testing. Unfortunately there is no easy way to delete them when we don't need them, this
section helps with removing them.

This section is not selected by default.

### Archives

When we create build for distrubution or export, a new archive is created. For each version it contains a build, debug symbols and 
other informations. Usually we need those archived items for crashes symbolications for example, but for sure we don't need all of them.
Xcode Cleaner allows to quickly inspect the archives and delete older ones or builds that are not on store.

This section is not selected by default.

### Derived Data

This is the major "cache" part of Xcode files, where autocompletion data, logs, debug builds, intermediate products and other stuff lives.
The point is that it could be regenerated if necessary. Also some older projects could be removed completely because its rather unusual that 
we would use them again.

## Contact

If you enjoy this application, consider support me, by downloading/buying some of my games from the AppStore 😎

Twitter: [@vashpan](https://twitter.com/vashpan), [@oneminutegames](https://twitter.com/OneMinuteGames)
Website: http://www.one-minute-games.com

## Contribution

This application is my first macOS app, so feel free to give me some feedback or pull requests! If there's some new feature to support, maybe some caches I missed, let me know as well in issues.

Application is licensed using GPL3.
