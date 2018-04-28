//
//  XcodeFiles.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 10.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation
import Cocoa

// MARK: Xcode files delegate
public protocol XcodeFilesDelegate: class {
    func scanWillBegin(xcodeFiles: XcodeFiles)
    func scanDidFinish(xcodeFiles: XcodeFiles)
}

// MARK: - Xcode files
final public class XcodeFiles {
    // MARK: Types
    public enum Location: Int {
        case deviceSupport, simulators, archives, derivedData
        
        public static var all: [Location] {
            return [.deviceSupport, .simulators, .archives, .derivedData]
        }
    }
    
    // MARK: Properties
    private let userDeveloperFolderUrl: URL
    private let systemDeveloperFolderUrl: URL
    
    public weak var delegate: XcodeFilesDelegate?
    
    public private(set) var locations: [Location : XcodeFileEntry]
    
    public var totalSize: Int64 {
        return locations.values.reduce(0) { (result, entry) -> Int64 in
            return result + (entry.size.numberOfBytes ?? 0)
        }
    }
    
    public var selectedSize: Int64 {
        return locations.values.reduce(0) { (result, entry) -> Int64 in
            return result + entry.selectedSize
        }
    }
    
    // MARK: Initialization
    public init?() {
        guard let userLibrariesUrl = try? FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            log.error("XcodeFiles: Cannot create because user Libraries folder is not available!")
            return nil
        }
        
        guard let systemLibrariesUrl = try? FileManager.default.url(for: .allLibrariesDirectory, in: .localDomainMask, appropriateFor: nil, create: false) else {
            log.error("XcodeFiles: Cannot create because system Libraries folder is not available!")
            return nil
        }
        
        self.userDeveloperFolderUrl = userLibrariesUrl.appendingPathComponent("Developer", isDirectory: true)
        self.systemDeveloperFolderUrl = systemLibrariesUrl.appendingPathComponent("Developer", isDirectory: true)
        
        guard XcodeFiles.checkForXcodeDataFolders(location: self.userDeveloperFolderUrl) else {
            log.error("XcodeFiles: Cannot create because Xcode cache folders doesn't seem to exist!")
            return nil
        }
        
        self.locations = [
            .deviceSupport: XcodeFileEntry(label: "Device Support", selected: true),
            .simulators: XcodeFileEntry(label: "Unused Simulators", selected: false),
            .archives: XcodeFileEntry(label: "Archives", selected: false),
            .derivedData: XcodeFileEntry(label: "Derived Data", selected: true)
        ]
    }
    
    // MARK: Helpers
    private static func checkForXcodeDataFolders(location: URL) -> Bool {
        // check if folder exists
        let folderExists = FileManager.default.fileExists(atPath: location.path)
        
        // more checks, like folders structure
        var structureProper = true
        
        let foldersToCheck = ["Xcode", "CoreSimulator"]
        for folder in foldersToCheck {
            let folderPath = location.appendingPathComponent(folder)
            
            if !FileManager.default.fileExists(atPath: folderPath.path) {
                structureProper = false
                break
            }
        }
        
        return folderExists && structureProper
    }
    
    public func checkForInstalledXcodes(completion: ([Version]) -> Void) {
        // TODO: Add real implementation
        completion([Version(major: 9, minor: 3)])
    }
    
    public func debugRepresentation() -> String {
        var result = String()
        
        for entry in self.locations.values {
            result += entry.debugRepresentation()
            result += "\n"
        }
        
        return result
    }
    
    // MARK: Creating entries
    private func deviceSupportEntry(from string: String) -> DeviceSupportFileEntry? {
        let splitted = string.split(separator: " ", maxSplits: 3, omittingEmptySubsequences: true)
        
        // we have device too
        if splitted.count == 3 {
            let device = String(splitted[0])
            let version = Version(describing: String(splitted[1]))
            let build = String(splitted[2])
            
            if let version = version {
                return DeviceSupportFileEntry(device: device, version: version, build: build, selected: true)
            } else {
                log.warning("XcodeFiles: No version for device support: \(string), skipping")
            }
        }
        
        // no device so only version and build
        if splitted.count == 2 {
            let version = Version(describing: String(splitted[0]))
            let build = String(splitted[1])
            
            if let version = version {
                return DeviceSupportFileEntry(device: nil, version: version, build: build, selected: true)
            } else {
                log.warning("XcodeFiles: No version for device support: \(string), skipping")
            }
        }
        
        return nil
    }
    
    private func simulatorRuntimeEntry(from string: String) -> SimulatorFileEntry? {
        let splitted = string.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        
        if splitted.count == 2 {
            let system = String(splitted[0])
            let systemVersion = Version(describing: String(splitted[1]))
            
            if let version = systemVersion {
                return SimulatorFileEntry(system: system, version: version, selected: false)
            } else {
                log.warning("XcodeFiles: No version for simulator: \(string), skipping")
            }
        }
        
        return nil
    }
    
    private func derivedDataEntry(from location: URL) -> DerivedDataFileEntry? {
        let splitted = location.lastPathComponent.split(separator: "-", maxSplits: 2, omittingEmptySubsequences: true)
        
        // check for project name
        let name: String
        if splitted.count == 2 {
            name = String(splitted[0]).replacingOccurrences(of: "_", with: " ") // replace all dashes with spaces
        } else {
            return nil
        }
        
        // find project folder path
        let infoPath = location.appendingPathComponent("info.plist")
        
        if let projectInfoDict = NSDictionary(contentsOf: infoPath) {
            // try to get project folder path from .plist dictionary
            if let projectRealPath = projectInfoDict["WorkspacePath"] as? String {
                let projectRealPathUrl = URL(fileURLWithPath: projectRealPath)
                
                return DerivedDataFileEntry(projectName: name, pathUrl: projectRealPathUrl, icon: .system(name: .folder), selected: true)
            }
        }
        
        return nil
    }
    
    private func archiveFileEntry(from location: URL) -> ArchiveFileEntry? {
        let splitted = location.lastPathComponent.split(separator: " ", maxSplits: 3, omittingEmptySubsequences: true)
        
        if splitted.count < 2 {
            return nil // probably completely not what we wanted, like .DS_Store file
        }
        
        // check for project name
        let projectName: String
        if let name = splitted.first {
            projectName = String(name)
        } else {
            log.warning("XcodeFiles: Cannot get project name from archive: \(location.path)")
            return nil
        }
        
        // open archive info.plist for more informations
        let bundleName: String
        let bundleVersion: Version
        let bundleBuild: String
        
        let infoPath = location.appendingPathComponent("Info.plist")
        if let archiveInfoDict = NSDictionary(contentsOf: infoPath) {
            if let archiveProperties = archiveInfoDict["ApplicationProperties"] as? [String : Any] {
                // bundle name
                if let bundle = archiveProperties["CFBundleIdentifier"] as? String {
                    bundleName = bundle
                } else {
                    log.warning("XcodeFiles: Cannot get bundle name from archive: \(location.path)")
                    return nil
                }
                
                // version
                if let versionString = archiveProperties["CFBundleShortVersionString"] as? String, let version = Version(describing: versionString) {
                    bundleVersion = version
                } else {
                    log.warning("XcodeFiles: Cannot get bundle version from archive: \(location.path)")
                    return nil
                }
                
                // build
                if let build = archiveProperties["CFBundleVersion"] as? String {
                    bundleBuild = build
                } else {
                    log.warning("XcodeFiles: Cannot get bundle build from archive: \(location.path)")
                    return nil
                }
            } else {
                log.warning("XcodeFiles: Cannot get 'ApplicationProperties' from archive Info.plist file: \(location.path)")
                return nil
            }
        } else {
            log.warning("XcodeFiles: Cannot open Info.plist file from archive: \(location.path)")
            return nil
        }
        
        return ArchiveFileEntry(projectName: projectName,
                                 bundleName: bundleName,
                                    version: bundleVersion,
                                      build: bundleBuild,
                                   location: location,
                                   selected: false)
    }
    
    // MARK: Scan files
    public func scanFiles(in locations: [Location]) {
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.scanWillBegin(xcodeFiles: strongSelf)
            }
        }
        
        for location in locations {
            self.scanFiles(in: location)
        }
        
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.scanDidFinish(xcodeFiles: strongSelf)
            }
        }
    }
    
    private func scanFiles(in location: Location) {
        guard let entry = self.locations[location] else {
            precondition(self.locations.keys.contains(location), "❌ No entry found for location: \(location)")
            return
        }
        
        // remove previous entries
        entry.removeAllChildren()
        
        // scan and find files
        switch location {
            case .deviceSupport:
                entry.addChildren(items: self.scanDeviceSupportLocations())
            
            case .simulators:
                entry.addChildren(items: self.scanSimulatorsLocations())
            
            case .archives:
                entry.addChildren(items: self.scanArchivesLocations())
            
            case .derivedData:
                entry.addChildren(items: self.scanDerivedDataLocations())
        }
        
        // check for those files sizes
        entry.recalculateSize()
        
        // check for selections
        entry.recalculateSelection()
    }
    
    private func scanDeviceSupportLocations() -> [XcodeFileEntry] {
        let deviceSupportEntries = [
            (entry: XcodeFileEntry(label: "iOS", selected: true), path: "iOS DeviceSupport"),
            (entry: XcodeFileEntry(label: "watchOS", selected: true), path: "watchOS DeviceSupport"),
            (entry: XcodeFileEntry(label: "tvOS", selected: true), path: "tvOS DeviceSupport")
        ]
        
        let xcodeLocation = self.userDeveloperFolderUrl.appendingPathComponent("Xcode")
        var entries: [XcodeFileEntry] = []
        for entry in deviceSupportEntries {
            let entryUrl = xcodeLocation.appendingPathComponent(entry.path)
            
            // scan for versions
            if let symbols = try? FileManager.default.contentsOfDirectory(at: entryUrl, includingPropertiesForKeys: nil) {
                var deviceSupportEntries = [XcodeFileEntry]()
                for symbolUrl in symbols {
                    if let deviceSupportEntry = self.deviceSupportEntry(from: symbolUrl.lastPathComponent) {
                        deviceSupportEntry.addPath(path: symbolUrl)
                        
                        deviceSupportEntries.append(deviceSupportEntry)
                    }
                }
                
                // sort
                deviceSupportEntries = deviceSupportEntries.sorted { (lhs, rhs) -> Bool in
                    lhs.label > rhs.label
                }
                
                // deselect first one (we usually will want those symbols)
                if let firstEntry = deviceSupportEntries.first {
                    firstEntry.deselectWithChildItems()
                }
                
                entry.entry.addChildren(items: deviceSupportEntries)
                
            } else {
                log.warning("XcodeFiles: Cannot check contents of '\(entryUrl)', skipping")
            }
            
            entries.append(entry.entry)
        }
        
        return entries
    }

    private func scanSimulatorsLocations() -> [XcodeFileEntry] {
        let simulatorsLocation = self.systemDeveloperFolderUrl.appendingPathComponent("CoreSimulator/Profiles/Runtimes")
        
        // scan for simulator runtimes
        var results: [XcodeFileEntry] = []
        if let simulators = try? FileManager.default.contentsOfDirectory(at: simulatorsLocation, includingPropertiesForKeys: nil) {
            for simulatorRuntimeUrl in simulators {
                if let simulatorEntry = self.simulatorRuntimeEntry(from: simulatorRuntimeUrl.deletingPathExtension().lastPathComponent) {
                    simulatorEntry.addPath(path: simulatorRuntimeUrl)
                    
                    results.append(simulatorEntry)
                }
            }
        }
        
        // TODO: Scan for simulators (~/Library/Developer/CoreSimulator/Devices), or use `xcrun simctl delete unavailable` command if possible, but only after runtime deletion
        
        results = results.sorted { (lhs, rhs) -> Bool in
            lhs.label > rhs.label
        }
        
        return results
    }
    
    private func scanArchivesLocations() -> [XcodeFileEntry] {
        let archivesLocation = self.userDeveloperFolderUrl.appendingPathComponent("Xcode/Archives")
        
        // gather various projects, create entries for each of them
        var archiveInfos = [String : [ArchiveFileEntry]]()
        if let datesFolders = try? FileManager.default.contentsOfDirectory(at: archivesLocation, includingPropertiesForKeys: nil) {
            for dateFolder in datesFolders {
                if let xcarchives = try? FileManager.default.contentsOfDirectory(at: dateFolder, includingPropertiesForKeys: nil) {
                    for xcarchive in xcarchives {
                        if let xcarchiveEntry = self.archiveFileEntry(from: xcarchive) {
                            if archiveInfos.keys.contains(xcarchiveEntry.bundleName) {
                                archiveInfos[xcarchiveEntry.bundleName]?.append(xcarchiveEntry)
                            } else {
                                archiveInfos[xcarchiveEntry.bundleName] = [xcarchiveEntry]
                            }
                        }
                    }
                }
            }
        }
        
        // convert archive infos for project entries
        return archiveInfos.compactMap { (arg) -> XcodeFileEntry? in
            let (_, archiveEntries) = arg
            
            guard let projectName = archiveEntries.first?.projectName else {
                return nil
            }
            
            // root project
            let projectEntry = XcodeFileEntry(label: projectName, selected: false)
            
            // sort by label
            let projectArchiveEntries = archiveEntries.sorted { (lhs, rhs) -> Bool in
                lhs.label > rhs.label
            }
            
            projectEntry.addChildren(items: projectArchiveEntries)
            
            return projectEntry
        }
    }
    
    private func scanDerivedDataLocations() -> [XcodeFileEntry] {
        let derivedDataLocation = self.userDeveloperFolderUrl.appendingPathComponent("Xcode/DerivedData")
        
        // scan for derived data projects
        var results: [XcodeFileEntry] = []
        if let projectsFolders = try? FileManager.default.contentsOfDirectory(at: derivedDataLocation, includingPropertiesForKeys: nil) {
            for projectFolder in projectsFolders {
                // ignore "ModuleCache" folder
                if projectFolder.lastPathComponent == "ModuleCache" {
                    continue
                }
                
                if let projectEntry = self.derivedDataEntry(from: projectFolder) {
                    projectEntry.addPath(path: projectFolder)
                    
                    results.append(projectEntry)
                }
            }
        }
        
        return results
    }
}
