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
    
    private var xcodeFiles: XcodeFiles?
    private var loaded = false
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check for installed Xcode versions
        self.checkForInstalledXcode()
        
        // set all time saved bytes label
        self.benefitsButton.attributedTitle = self.benefitsButtonAttributedString(totalBytesCleaned: Preferences.shared.totalBytesCleaned)
        
        // open ~/Library/Developer folder & create XcodeFiles instance
        guard let developerLibraryFolder = self.acquireUserDeveloperFolderPermissions(),
              let systemLibraryFolder = self.acquireSystemDeveloperFolderPermissions(),
              let xcodeFiles = XcodeFiles(developerFolder: developerLibraryFolder, systemDeveloperFolder: systemLibraryFolder) else {
            log.error("MainViewController: Cannot create XcodeFiles instance!")
            
            //Preferences.shared.devFolderBookmark = nil // reset data bookmark in case we choose wrong folder
            
            Messages.fatalErrorMessageAndQuit(title: "Cannot locate Xcode cache files, or can't get access to ~/Library/Developer folder",
                                              message: "Check if you have Xcode installed and some projects built. Also, in the next run check if you selected proper folder.")
            return
        }
        
        xcodeFiles.scanDelegate = self
        self.xcodeFiles = xcodeFiles
    
        // start initial scan
        self.startScan()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.view.window?.delegate = self
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
        }
    }
    
    // MARK: Helpers
    private func startScan() {
        guard let xcodeFiles = self.xcodeFiles else {
            log.error("MainViewController: Cannot create XcodeFiles instance!")
            return
        }
        
        // clear data
        xcodeFiles.cleanAllEntries()
        
        self.updateTotalAndSelectedSizes()
        
        // start scan asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            xcodeFiles.scanFiles(in: XcodeFiles.Location.all)
        }
    }
    
    @discardableResult
    private func acquireUserDeveloperFolderPermissions() -> URL? {
        let userName = NSUserName()
        let userHomeDirectory = URL(fileURLWithPath: "/Users/\(userName)")
        let userDeveloperFolder = userHomeDirectory.appendingPathComponent("Library/Developer", isDirectory: true)
        
        return userDeveloperFolder.acquireAccessFromSandbox(bookmark: Preferences.shared.folderBookmark(for: userDeveloperFolder),
                                                        openPanelMessage: "DevCleaner needs permission to your Developer folder to scan Xcode cache files. Folder should be already selected and all you need to do is to click \"Open\".")
    }
    
    @discardableResult
    private func acquireSystemDeveloperFolderPermissions() -> URL? {
        let systemDeveloperFolder = URL(fileURLWithPath: "/Library/Developer")
        
        return systemDeveloperFolder.acquireAccessFromSandbox(bookmark: Preferences.shared.folderBookmark(for: systemDeveloperFolder),
                                                              openPanelMessage: "DevCleaner needs permission to your Developer folder to scan Xcode cache files. Folder should be already selected and all you need to do is to click \"Open\".")
    }
    
    private func checkForInstalledXcode() {
        if NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: "com.apple.dt.Xcode") == nil {
            Messages.fatalErrorMessageAndQuit(title: "Xcode cannot be found",
                                              message: "Check if you have Xcode installed")
        }
    }
    
    private func formatBytesToString(bytes: Int64) -> String {
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    private func updateTotalAndSelectedSizes() {
        guard let xcodeFiles = self.xcodeFiles else {
            log.error("MainViewController: Cannot create XcodeFiles instance!")
            return
        }
        
        // total size
        let totalSizeString = self.formatBytesToString(bytes: xcodeFiles.totalSize)
        self.totalBytesTextField.stringValue = "Total: \(totalSizeString)"
        self.view.window?.title = "DevCleaner - \(totalSizeString) available to clean"
        
        // selected size
        self.bytesSelectedTextField.stringValue = "Selected: \(self.formatBytesToString(bytes: xcodeFiles.selectedSize))"
        
        // all time size / donate button
        self.benefitsButton.attributedTitle = self.benefitsButtonAttributedString(totalBytesCleaned: Preferences.shared.totalBytesCleaned)
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
            log.error("MainViewController: Cannot create XcodeFiles instance!")
            return
        }
        
        // show warning message with question if we want to proceed and continue only if we agree
        let dryRunEnabled = Preferences.shared.dryRunEnabled
        let warningMessage = dryRunEnabled ? "DevCleaner is running in \"dry run\" mode. It means that files won't be deleted and nothing will change. If you want to clean files for real, go to \"Preferences\" and disable dry run mode."
                                           : "Are you sure to proceed? This can't be undone."
        Messages.warningMessage(title: "Clean Xcode cache files", message: warningMessage, okButtonText: "Clean", window: self.view.window) { (messageResult) in
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
    
    @IBAction func showGitHubPage(_ sender: Any) {
        if let gitHubUrl = URL(string: "https://github.com/vashpan/xcode-dev-cleaner") {
            NSWorkspace.shared.open(gitHubUrl)
        }
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
            
            self.updateTotalAndSelectedSizes()
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

        self.updateTotalAndSelectedSizes()
    }
}
