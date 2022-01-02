#  Command Line Tool

## Installing 

Due to restrictions on Mac App Store, command line tool cannot be installed by DevCleaner itself, it'll require some manual work.

Follow those instructions to install command line tool:

This instructions assumes you have **DevCleaner** installed in `/Applications` folder. If you moved it, or installed it in a different location, please include it in instructions given below.

You need admistrator rights to install it in the location proposed in this instructions.

1. Open "Terminal" app
2. Type `sudo cp /Applications/DevCleaner.app/Contents/Resources/dev-cleaner.sh /usr/local/bin/dev-cleaner`
3. Enter your password if needed

You can change destination path if you like, just remember that it has to be in your `PATH` if you want to use it from anywhere in your system.

Please note that if you have multiple copies of DevCleaner installed, command line tool will use the most recent used.

## Usage

```
DevCleaner 2.0.0

OVERVIEW: Reclaims storage that Xcode stores in caches and old files

USAGE: DevCleaner <command> [options]

OPTIONS:

    info
        Show all items available to clean.
    clean <all,device-support,archives,derived-data,old-logs,old-documentation>
        Perform cleaning of given items. Available options: all,device-support,archives,derived-data,old-logs,old-documentation. If you want to clean all, pass "all"
    --help
        Prints this message
```

Please note that command line tool doesn't allow to select specific items, it's designed to run mostly in maintanance scripts or CI machines.
