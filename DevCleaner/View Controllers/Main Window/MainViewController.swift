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
    @IBOutlet private weak var benefitsButton: NSButton!
    
    @IBOutlet private weak var outlineView: NSOutlineView!
    
    @IBOutlet private weak var dryModeView: NSView!
    
    private var xcodeFiles: XcodeFiles?
    private var loaded = false
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dryModeView.wantsLayer = true
        
        // observe preferences
        Preferences.shared.addObserver(self)
        
        // open ~/Library/Developer folder, create XcodeFiles instance and start scanning
        self.setupXcodeFilesAndStartScanningIfNeeded()
        
        // set all time saved bytes label
        self.benefitsButton.attributedTitle = self.benefitsButtonAttributedString(totalBytesCleaned: Preferences.shared.totalBytesCleaned)
    }
    
    deinit {
        Preferences.shared.removeObserver(self)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // UI refresh
        self.updateButtonsAndLabels()
        
        self.view.window?.delegate = self
    }
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == 49 { // spacebar
            let selectedRow = self.outlineView.selectedRow
            if let selectedEntry = self.outlineView.item(atRow: selectedRow) as? XcodeFileEntry,
               let selectedCellView = self.outlineView.view(atColumn: 0, row: selectedRow, makeIfNecessary: false) as? XcodeEntryCellView {
                let targetStateValue: NSControl.StateValue
                switch selectedEntry.selection {
                    case .on:
                        targetStateValue = .off
                    case .off:
                        targetStateValue = .on
                    case .mixed:
                        targetStateValue = .on
                }
                
                self.xcodeEntryCellSelectedChanged(selectedCellView, state: targetStateValue, xcodeEntry: selectedEntry)
                
                self.outlineView.selectRowIndexes([selectedRow], byExtendingSelection: false)
            }
        }
        
        super.keyUp(with: event)
    }
    
    // MARK: Navigation
    private func prepareCleaningView(with segue: NSStoryboardSegue) {
        if let cleaningViewController = segue.destinationController as? CleaningViewController {
            cleaningViewController.state = .idle(title: "Initialization...", indeterminate: true, doneButtonEnabled: false)
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
        
        // open ~/Library/Developer folder & create XcodeFiles instance
        if let developerLibraryFolder = Files.acquireUserDeveloperFolderPermissions(),
           let xcodeFiles = XcodeFiles(developerFolder: developerLibraryFolder,
                                       customDerivedDataFolder: Files.acquireCustomDerivedDataFolderPermissions(),
                                       customArchivesFolder: Files.acquireCustomArchivesFolderPermissions()) {
            xcodeFiles.scanDelegate = self
            self.xcodeFiles = xcodeFiles
            
            // start initial scan
            self.startScan()
        } else {
            log.warning("MainViewController: Cannot create XcodeFiles instance!")
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
        
        // total size & free disk space
        if let xcodeFiles = self.xcodeFiles {
            let totalSizeAvailableToCleanString = self.formatBytesToString(bytes: xcodeFiles.totalSize)
            let bytesFreeOnDisk = (try? fileManager.volumeFreeDiskSpace(at: Files.userDeveloperFolder)) ?? 0
            let bytesFreeOnDiskString = self.formatBytesToString(bytes: bytesFreeOnDisk)
            self.totalBytesTextField.stringValue = "Total: \(totalSizeAvailableToCleanString)"
            self.view.window?.title = "DevCleaner - \(totalSizeAvailableToCleanString) available to clean, \(bytesFreeOnDiskString) free on disk"
        }
        
        // selected size
        let selectedSize = xcodeFiles?.selectedSize ?? 0
        self.bytesSelectedTextField.stringValue = "Selected: \(self.formatBytesToString(bytes: selectedSize))"
        
        // clean button disabled when we selected nothing
        self.cleanButton.isEnabled = selectedSize > 0
        
        // all time size / donate button
        self.benefitsButton.attributedTitle = self.benefitsButtonAttributedString(totalBytesCleaned: Preferences.shared.totalBytesCleaned)
        
        // dry mode label
        self.dryModeView.isHidden = !Preferences.shared.dryRunEnabled
        self.dryModeView.layer?.backgroundColor = NSColor.systemOrange.cgColor
        self.dryModeView.layer?.cornerRadius = 4.0
        self.dryModeView.layer?.masksToBounds = true
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
    
    private func formatBytesToString(bytes: Int64) -> String {
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    private func benefitsButtonAttributedString(totalBytesCleaned: Int64) -> NSAttributedString {
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
            
            let partThree = NSAttributedString(string: "! Tip me or share it!",
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
    
    // MARK: Actions
    @IBAction func startCleaning(_ sender: NSButton) {
        guard let xcodeFiles = self.xcodeFiles else {
            return
        }
        
        // show warning message with question if we want to proceed and continue only if we agree
        let dryRunEnabled = Preferences.shared.dryRunEnabled
        let warningMessage = dryRunEnabled ? "DevCleaner is running in \"dry run\" mode. It means that files won't be deleted and nothing will change. If you want to clean files for real, go to \"Preferences\" and disable dry run mode."
                                           : "Are you sure to proceed? This can't be undone."
        Alerts.warningAlert(title: "Clean Xcode cache files", message: warningMessage, okButtonText: "Clean", window: self.view.window) { (messageResult) in
            if messageResult == .alertFirstButtonReturn {
                self.performSegue(withIdentifier: Segue.showCleaningView.segueIdentifier, sender: nil)
                
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
        guard let clickedEntry = self.outlineView.item(atRow: self.outlineView.clickedRow) as? XcodeFileEntry else {
            return
        }
        
        if clickedEntry.paths.count > 0 {
            NSWorkspace.shared.activateFileViewerSelecting(clickedEntry.paths)
        }
    }
    
    @IBAction func rescan(_ sender: Any) {
        self.startScan()
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
    func didDismissViewController(_ vc: CleaningViewController) {
        self.startScan()
    }
}

// MARK: XcodeFilesScanDelegate implementation
extension MainViewController: XcodeFilesScanDelegate {
    func scanWillBegin(xcodeFiles: XcodeFiles) {
        self.startLoading()
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
