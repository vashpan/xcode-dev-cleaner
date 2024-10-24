//
//  MainViewController.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 11.02.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
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
import StoreKit

final class MainViewController: NSViewController {
    // MARK: Types
    private enum OutlineViewColumnsIdentifiers: String {
        case itemColumn = "ItemColumn"
        case sizeColumn = "SizeColumn"
        
        var identifier: NSUserInterfaceItemIdentifier {
            return NSUserInterfaceItemIdentifier(self.rawValue)
        }
    }
    
    private enum OutlineViewCellIdentifiers: String {
        case itemCell = "ItemCell"
        case sizeCell = "SizeCell"
        
        var identifier: NSUserInterfaceItemIdentifier {
            return NSUserInterfaceItemIdentifier(self.rawValue)
        }
    }
    
    private enum Segue: String {
        case showCleaningView = "ShowCleaningView"
        case showDonateView = "ShowDonateView"
        
        var segueIdentifier: NSStoryboardSegue.Identifier {
            return self.rawValue
        }
    }
    
    // MARK: Properties & outlets
    @IBOutlet private weak var bytesSelectedTextField: NSTextField!
    @IBOutlet private weak var totalBytesTextField: NSTextField!
    
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    @IBOutlet private weak var cleanButton: NSButton!
    @IBOutlet private weak var benefitsTextField: NSTextField!
    @IBOutlet private weak var tipMeButton: NSButton!
    
    @IBOutlet weak var accessWarningsView: NSView!
    @IBOutlet weak var accessWarningTitle: NSTextField!
    @IBOutlet weak var accessWarningContent: NSTextField!
    @IBOutlet weak var accessWarningButton: NSButton!
    
    @IBOutlet private weak var outlineView: NSOutlineView!
    
    private weak var dryModeView: NSView!
    
    private var xcodeFiles: XcodeFiles?
    private var loaded = false
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // observe preferences
        Preferences.shared.addObserver(self)
        
        self.disableAccessWarnings()
        
        // open ~/Library/Developer folder, create XcodeFiles instance and start scanning
        if XcodeFiles.isDeveloperFolderExists() {
            self.setupXcodeFilesAndStartScanningIfNeeded()
        } else {
            self.enableAccessWarnings(title: "\"~/Developer\" folder cannot be found",
                                      content: "DevCleaner main function is to clean unnecessary files in this folder. Without it, it won't be very useful. This folder is usually created by Xcode during work. Make sure you've installed it.",
                                      buttonTitle: "Download Xcode",
                                      buttonActionSelector: #selector(downloadXcode(_:)))
        }
        
        // set all time saved bytes label
        self.benefitsTextField.attributedStringValue = self.benefitsLabelAttributedString(totalBytesCleaned: Preferences.shared.totalBytesCleaned)
    }
    
    deinit {
        Preferences.shared.removeObserver(self)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // UI refresh
        self.updateButtonsAndLabels()
        
        // notify about Xcode being open
        let showXcodeWarning = Preferences.shared.showXcodeWarning
        if showXcodeWarning && XcodeFiles.isXcodeRunning() {
            Alerts.warningAlert(title: "Xcode is open",
                                message: "DevCleaner can run with Xcode being opened, but cleaning some files may affect Xcode functions and maybe even cause its crash.",
                                okButtonText: "Continue",
                                cancelButtonText: "Close DevCleaner") { messageResult in
                if messageResult == .alertSecondButtonReturn {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        
        self.view.window?.delegate = self
    }
    
    func toggleRow(_ row: Int) {
        guard let selectedEntry = self.outlineView.item(atRow: row) as? XcodeFileEntry,
              let selectedCellView = self.outlineView.view(atColumn: 0, row: row, makeIfNecessary: false) as? XcodeEntryCellView else {
            return
        }

        let targetStateValue: NSControl.StateValue
        switch selectedEntry.selection {
            case .on:
                targetStateValue = .off
            case .off:
                targetStateValue = .on
            case .mixed:
                targetStateValue = .on
        }
        
        self.xcodeEntryCellSelectedChanged(selectedCellView, state: targetStateValue,
                                           xcodeEntry: selectedEntry)
    }
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == 49 { // spacebar
            for row in self.outlineView.selectedRowIndexes {
                toggleRow(row)
            }
        }
        
        super.keyUp(with: event)
    }
    
    // MARK: Navigation
    private func prepareCleaningView(with segue: NSStoryboardSegue) {
        if let cleaningViewController = segue.destinationController as? CleaningViewController {
            cleaningViewController.state = .idle(title: "Initialization...", progress: 0.0)
            cleaningViewController.delegate = self
            
            self.xcodeFiles?.deleteDelegate = cleaningViewController
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueId = Segue(rawValue: identifier) else {
            log.warning("MainViewController: Unrecognized segue: \(segue)")
            return
        }
        
        switch segueId {
            case .showCleaningView:
                self.prepareCleaningView(with: segue)
            case .showDonateView:
                break // nothing to be done here
        }
    }
    
    // MARK: Helpers
    private func setupXcodeFilesAndStartScanningIfNeeded() {
        guard self.xcodeFiles == nil else {
            return
        }
        
        // reset custom folders to default if they don't exists
        let fm = FileManager.default
        if let customDerivedDataPath = Preferences.shared.customDerivedDataFolder?.path, !fm.fileExists(atPath: customDerivedDataPath) {
            log.warning("Custom derived data folder no longer exists, resetting to default!")
            Preferences.shared.customDerivedDataFolder = nil
        }
        
        if let customArchivesPath = Preferences.shared.customArchivesFolder?.path, !fm.fileExists(atPath: customArchivesPath) {
            log.warning("Custom archives folder no longer exists, resetting to default!")
            Preferences.shared.customArchivesFolder = nil
        }
        
        
        // open ~/Library/Developer folder & create XcodeFiles instance
        if let developerLibraryFolder = Files.acquireUserDeveloperFolderPermissions(),
           let xcodeFiles = XcodeFiles(developerFolder: developerLibraryFolder,
                                       customDerivedDataFolder: Files.acquireCustomDerivedDataFolderPermissions(),
                                       customArchivesFolder: Files.acquireCustomArchivesFolderPermissions()) {
            xcodeFiles.scanDelegate = self
            self.xcodeFiles = xcodeFiles
            
            self.disableAccessWarnings()
            
            // start initial scan
            self.startScan()
        } else {
            log.warning("MainViewController: Cannot acquire \"Developer\" folder access! Showing access warning!")
            
            self.enableAccessWarnings(title: "Access to \"~/Developer\" folder is needed",
                                      content: "DevCleaner needs permission to your Developer folder to scan Xcode cache files & archives",
                                      buttonTitle: "Give Access",
                                      buttonActionSelector: #selector(selectDeveloperFolder(_:)))
        }
    }
    
    private func updateCustomFolders() {
        guard let xcodeFiles = self.xcodeFiles else {
            return
        }
        
        let derivedDataFolder = Files.acquireCustomDerivedDataFolderPermissions()
        let archivesFolder = Files.acquireCustomArchivesFolderPermissions()
        
        xcodeFiles.updateCustomFolders(customDerivedDataFolder: derivedDataFolder,
                                       customArchivesFolder: archivesFolder)
    }
    
    private func updateButtonsAndLabels() {
        let fileManager = FileManager.default
        
        // dry mode label
        if let window = self.view.window {
            if window.titlebarAccessoryViewControllers.count == 0 {
                let dryLabelAccessoryVc = NSTitlebarAccessoryViewController()
                dryLabelAccessoryVc.layoutAttribute = .trailing
                dryLabelAccessoryVc.view = NSView(frame: NSRect(x: 0.0, y: 0.0, width: 80.0, height: 0.0))
                
                let dryModeView = NSView(frame: NSRect(x: 10.0, y: 6.0, width: 60.0, height: 16.0))
                dryModeView.wantsLayer = true
                dryModeView.layer?.backgroundColor = NSColor.systemOrange.cgColor
                dryModeView.layer?.cornerRadius = 4.0
                dryModeView.layer?.masksToBounds = true
                
                let dryModeLabel = NSTextField(labelWithString: "DRY MODE")
                dryModeLabel.frame = NSRect(x: 0.0, y: -2.0, width: 60.0, height: 16.0)
                dryModeLabel.font = NSFont.labelFont(ofSize: 9.0)
                dryModeLabel.textColor = .white
                dryModeLabel.alignment = .center
                dryModeLabel.lineBreakMode = .byClipping
                dryModeView.addSubview(dryModeLabel)
                
                dryLabelAccessoryVc.view.addSubview(dryModeView)
                self.view.window?.addTitlebarAccessoryViewController(dryLabelAccessoryVc)
                
                self.dryModeView = dryModeView
            }
            self.dryModeView.isHidden = !Preferences.shared.dryRunEnabled
        }
        
        // total size & free disk space
        let bytesFreeOnDisk = (try? fileManager.volumeFreeDiskSpace(at: Files.userDeveloperFolder)) ?? 0
        let bytesFreeOnDiskString = self.formatBytesToString(bytes: bytesFreeOnDisk)
        
        if let xcodeFiles = self.xcodeFiles, xcodeFiles.state == .scanComplete {
            let totalSizeAvailableToCleanString = self.formatBytesToString(bytes: xcodeFiles.totalSize)
            
            self.totalBytesTextField.stringValue = "Total: \(totalSizeAvailableToCleanString)"
            self.view.window?.title = "DevCleaner - \(totalSizeAvailableToCleanString) available to clean; \(bytesFreeOnDiskString) free on disk"
        } else {
            let zeroBytesAvailableToCleanString = self.formatBytesToString(bytes: 0)
            
            self.totalBytesTextField.stringValue = "Total: \(zeroBytesAvailableToCleanString)"
            self.view.window?.title = "DevCleaner - \(bytesFreeOnDiskString) free on disk"
        }
        
        // selected size
        let selectedSize = xcodeFiles?.selectedSize ?? 0
        self.bytesSelectedTextField.stringValue = "Selected: \(self.formatBytesToString(bytes: selectedSize))"
        
        // clean button disabled when we selected nothing
        self.cleanButton.isEnabled = selectedSize > 0
        
        // all time size / donate button
        self.benefitsTextField.attributedStringValue = self.benefitsLabelAttributedString(totalBytesCleaned: Preferences.shared.totalBytesCleaned)
        self.tipMeButton.isEnabled = Donations.shared.canMakeDonations
    }
    
    private func startScan() {
        guard let xcodeFiles = self.xcodeFiles else {
            return
        }
        
        // clear data
        xcodeFiles.cleanAllEntries()
        
        self.updateButtonsAndLabels()
        
        // start scan asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            xcodeFiles.scanFiles(in: xcodeFiles.locations.keys.map { $0 })
        }
    }
    
    private func playCompletionSound() {
        guard let sound = NSSound(named: "Blow") else {
            log.error("MainViewController: Completion sound 'Blow' not found!")
            return
        }
        
        sound.play()
    }
    
    private func formatBytesToString(bytes: Int64) -> String {
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    private func benefitsLabelAttributedString(totalBytesCleaned: Int64) -> NSAttributedString {
        let totalBytesString = ByteCountFormatter.string(fromByteCount: totalBytesCleaned, countStyle: .file)
        
        let fontSize: CGFloat = 12.0
        let result = NSMutableAttributedString()
        
        if totalBytesCleaned > 0 {
            let partOne = NSAttributedString(string: "You saved total of ",
                                             attributes: [.font : NSFont.systemFont(ofSize: fontSize)])
            result.append(partOne)
            
            let partTwo = NSAttributedString(string: "\(totalBytesString)",
                attributes: [.font : NSFont.boldSystemFont(ofSize: fontSize)])
            result.append(partTwo)
            
            let partThree = NSAttributedString(string: "! Tip me or share it:",
                                               attributes: [.font : NSFont.systemFont(ofSize: fontSize)])
            result.append(partThree)
        } else {
            let oneAndOnlyPart = NSAttributedString(string: "Like this app? You can tip me or share it!",
                                                    attributes: [.font : NSFont.systemFont(ofSize: fontSize)])
            
            result.append(oneAndOnlyPart)
        }
        
        return result
    }
    
    // MARK: Loading
    private func startLoading() {
        self.loaded = false
        
        self.outlineView.reloadData()
        
        self.progressIndicator.isHidden = false
        self.progressIndicator.startAnimation(nil)
        
        self.cleanButton.isEnabled = false
    }
    
    private func stopLoading() {
        self.loaded = true
        
        self.progressIndicator.stopAnimation(nil)
        self.progressIndicator.isHidden = true
        
        self.cleanButton.isEnabled = true
        
        self.outlineView.reloadData()
    }
    
    // MARK: Access Warnings
    private func disableAccessWarnings() {
        self.accessWarningsView.isHidden = true
    }
    
    private func enableAccessWarnings(title: String, content: String, buttonTitle: String, buttonActionSelector: Selector) {
        self.accessWarningTitle.stringValue = title
        self.accessWarningContent.stringValue = content
        
        self.accessWarningButton.title = buttonTitle
        self.accessWarningButton.target = self
        self.accessWarningButton.action = buttonActionSelector
        
        self.accessWarningsView.isHidden = false
    }
    
    // MARK: Actions
    @IBAction func startCleaning(_ sender: NSButton) {
        guard let xcodeFiles = self.xcodeFiles else {
            return
        }
        
        // show warning message with question if we want to proceed and continue only if we agree
        let dryRunEnabled = Preferences.shared.dryRunEnabled
        let warningMessage = dryRunEnabled ? "DevCleaner is running in \"dry run\" mode. It means that files won't be deleted and nothing will change. If you want to clean files for real, go to \"Preferences\" and disable dry run mode."
                                           : "Are you sure to proceed? This can't be undone."
        Alerts.warningAlert(title: "Clean Xcode cache files", message: warningMessage, okButtonText: "Clean", window: self.view.window) { messageResult in
            if messageResult == .alertFirstButtonReturn {
                self.performSegue(withIdentifier: Segue.showCleaningView.segueIdentifier, sender: nil)
                
                // in debug "dry" cleaned bytes are added to total bytes clean
                #if DEBUG
                Preferences.shared.totalBytesCleaned += xcodeFiles.selectedSize
                #else
                if !dryRunEnabled {
                    Preferences.shared.totalBytesCleaned += xcodeFiles.selectedSize
                }
                #endif
                
                log.info("MainViewController: Total bytes cleaned - \(self.formatBytesToString(bytes: Preferences.shared.totalBytesCleaned))")
                
                DispatchQueue.global(qos: .userInitiated).async {
                    xcodeFiles.deleteSelectedEntries(dryRun: dryRunEnabled)
                }
            }
        }
    }
    
    @IBAction func showInFinder(_ sender: Any) {
        var clickedEntries = [XcodeFileEntry]()
        for row in self.outlineView.selectedRowIndexes {
            if let clickedEntry = self.outlineView.item(atRow: row) as? XcodeFileEntry {
                clickedEntries.append(clickedEntry)
            }
        }

        let paths = [URL](clickedEntries.map(\.paths).joined())
        if paths.count > 0 {
            NSWorkspace.shared.activateFileViewerSelecting(paths)
        }
    }
    
    @IBAction func rescan(_ sender: Any) {
        self.startScan()
    }
    
    @IBAction func share(_ sender: Any) {
        guard let shareUrl = URL(string: "https://itunes.apple.com/app/devcleaner/id1388020431") else {
            return
        }
        
        guard let shareView = sender as? NSView else {
            return
        }
        
        let sharingService = NSSharingServicePicker(items: [shareUrl])
        sharingService.show(relativeTo: .zero, of: shareView, preferredEdge: .minX)
    }
    
    @IBAction func openAppReview(_ sender: Any) {
        ReviewRequests.shared.showReviewOnTheAppStore()
    }
    
    @IBAction func openFollowMenu(_ sender: NSButton) {
        guard let followMenu = sender.menu else {
            return
        }
        
        guard let event = NSApplication.shared.currentEvent else {
            return
        }
        
        NSMenu.popUpContextMenu(followMenu, with: event, for: sender)
    }
    
    @IBAction func followMeOnTwitter(_ sender: Any) {
        guard let myTwitterUrl = URL(string: "https://twitter.com/intent/follow?screen_name=vashpan") else {
            return
        }
        
        NSWorkspace.shared.open(myTwitterUrl)
    }
    
    @IBAction func followMeOnMastodon(_ sender: Any) {
        guard let myMastodonUrl = URL(string: "https://mastodon.social/@kkolakowski") else {
            return
        }
        
        NSWorkspace.shared.open(myMastodonUrl)
    }
    
    @IBAction func downloadXcode(_ sender: Any) {
        guard let xcodeUrl = URL(string: "https://apps.apple.com/pl/app/xcode/id497799835?") else {
            return
        }
        
        NSWorkspace.shared.open(xcodeUrl)
    }
    
    @IBAction func selectDeveloperFolder(_ sender: Any) {
        self.setupXcodeFilesAndStartScanningIfNeeded()
    }
}

// MARK: NSOutlineViewDataSource implementation
extension MainViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // no items if not loaded
        if !self.loaded {
            return 0
        }
        
        guard let xcodeFiles = self.xcodeFiles else {
            fatalError("MainViewController: Cannot create XcodeFiles instance!")
        }
        
        // for child items
        if let xcodeFileEntry = item as? XcodeFileEntry {
            return xcodeFileEntry.items.count
        }
        
        // for root items
        return xcodeFiles.locations.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let xcodeFiles = self.xcodeFiles else {
            fatalError("MainViewController: Cannot create XcodeFiles instance!")
        }
        
        // for child items
        if let xcodeFileEntry = item as? XcodeFileEntry {
            return xcodeFileEntry.items[index]
        }
        
        // for root items
        if let location = XcodeFiles.Location(rawValue: index), let xcodeFileEntry = xcodeFiles.locations[location] {
            return xcodeFileEntry
        } else {
            fatalError("MainViewController: Wrong location from index for XcodeFiles!")
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        // every item that has child items
        if let xcodeFileEntry = item as? XcodeFileEntry {
            return xcodeFileEntry.items.count > 0
        }
        
        return false
    }
}

// MARK: NSOutlineViewDelegate implementation
extension MainViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        if let xcodeFileEntry = item as? XcodeFileEntry, let column = tableColumn {
            if column.identifier == OutlineViewColumnsIdentifiers.itemColumn.identifier {
                if let itemView = outlineView.makeView(withIdentifier: OutlineViewCellIdentifiers.itemCell.identifier, owner: self) as? XcodeEntryCellView {
                    itemView.setup(with: xcodeFileEntry, delegate: self)
                    
                    view = itemView
                }
            } else if column.identifier == OutlineViewColumnsIdentifiers.sizeColumn.identifier {
                if let sizeView = outlineView.makeView(withIdentifier: OutlineViewCellIdentifiers.sizeCell.identifier, owner: self) as? SizeCellView {
                    sizeView.setup(with: xcodeFileEntry)
                    
                    view = sizeView
                }
            }
        }
        
        return view
    }
}

extension MainViewController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        self.xcodeFiles = nil
    }
}

// MARK: NSMenuDelegate implementation
extension MainViewController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        guard menu == self.outlineView.menu else {
            return
        }
        
        guard let showInFinderMenuItem = menu.item(at: 0) else {
            return
        }
        
        guard let clickedEntry = self.outlineView.item(atRow: self.outlineView.clickedRow) as? XcodeFileEntry else {
            return
        }
        
        if clickedEntry.paths.count > 0 {
            showInFinderMenuItem.isEnabled = true
        } else {
            showInFinderMenuItem.isEnabled = false
        }
    }
}

// MARK: XcodeEntryCellViewDelegate implementation
extension MainViewController: XcodeEntryCellViewDelegate {
    func xcodeEntryCellSelectedChanged(_ cell: XcodeEntryCellView, state: NSControl.StateValue, xcodeEntry: XcodeFileEntry?) {
        if let item = xcodeEntry {
            if state == .on {
                item.selectWithChildItems()
            } else if state == .off {
                item.deselectWithChildItems()
            }
            
            // create a list of current and parent items
            var rootEntry: XcodeFileEntry = item.parent ?? item
            var itemsToRefresh: [XcodeFileEntry] = [rootEntry]
            while let parentEntry = rootEntry.parent {
                itemsToRefresh.append(parentEntry)
                rootEntry = parentEntry
            }
            rootEntry.recalculateSelection()
            
            // refresh parent items and current item
            for itemToRefresh in itemsToRefresh {
                self.outlineView.reloadItem(itemToRefresh, reloadChildren: false)
            }
            self.outlineView.reloadItem(item, reloadChildren: true)
            
            self.updateButtonsAndLabels()
        }
    }
}

// MARK: CleaningViewControllerDelegate implememntation
extension MainViewController: CleaningViewControllerDelegate {
    func cleaningDidFinish(_ vc: CleaningViewController) {
        self.playCompletionSound()
        self.startScan()
        
        // ask after a little delay to let user enjoy their finished clean
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 2.0) {
            ReviewRequests.shared.requestReviewIfNeeded()
        }
    }
}

// MARK: XcodeFilesScanDelegate implementation
extension MainViewController: XcodeFilesScanDelegate {
    func scanWillBegin(xcodeFiles: XcodeFiles) {
        self.startLoading()
        
        self.updateButtonsAndLabels()
    }
    
    func scanDidFinish(xcodeFiles: XcodeFiles) {
        self.stopLoading()

        self.updateButtonsAndLabels()
    }
}

// MARK: PreferencesObserver implementation
extension MainViewController: PreferencesObserver {
    func preferenceDidChange(key: String) {
        if key == Preferences.Keys.customArchivesFolder || key == Preferences.Keys.customDerivedDataFolder {
            self.updateCustomFolders()
            self.startScan()
        }
        
        self.updateButtonsAndLabels()
    }
}
