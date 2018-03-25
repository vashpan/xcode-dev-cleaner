//
//  XcodeFiles.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 10.03.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation

// MARK: Xcode files delegate
public protocol XcodeFilesDelegate: class {
    func scanWillBegin(for location: XcodeFiles.Location, entry: XcodeFileEntry)
    
    func scanDidFinish(for location: XcodeFiles.Location, entry: XcodeFileEntry)
    func sizesCheckDidFinish(for location: XcodeFiles.Location, entry: XcodeFileEntry)
}

// MARK: - Xcode files
final public class XcodeFiles {
    // MARK: Types
    public enum Location: Int {
        case deviceSupport, simulators, archives, derivedData
    }
    
    // MARK: Properties
    private let userDeveloperFolderUrl: URL
    private let systemDeveloperFolderUrl: URL
    
    public weak var delegate: XcodeFilesDelegate?
    
    public private(set) var locations: [Location : XcodeFileEntry]
    
    // MARK: Initialization
    public init?() {
        guard let userLibrariesUrl = try? FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        
        guard let systemLibrariesUrl = try? FileManager.default.url(for: .allLibrariesDirectory, in: .localDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        
        self.userDeveloperFolderUrl = userLibrariesUrl.appendingPathComponent("Developer", isDirectory: true)
        self.systemDeveloperFolderUrl = systemLibrariesUrl.appendingPathComponent("Developer", isDirectory: true)
        
        guard XcodeFiles.checkForXcode(location: self.userDeveloperFolderUrl) else {
            return nil
        }
        
        self.locations = [
            .deviceSupport: XcodeFileEntry(label: "Device Support", selected: true),
            .simulators: XcodeFileEntry(label: "Simulators", selected: false),
            .archives: XcodeFileEntry(label: "Archives", selected: false),
            .derivedData: XcodeFileEntry(label: "Derived Data", selected: true)
        ]
    }
    
    // MARK: Helpers
    private static func checkForXcode(location: URL) -> Bool {
        // check if folder exists
        let folderExists = FileManager.default.fileExists(atPath: location.path)
        
        // more checks, like folders structure
        var structureProper = true
        
        let foldersToCheck = ["Xcode", "CoreSimulator", "Shared/Documentation"]
        for folder in foldersToCheck {
            let folderPath = location.appendingPathComponent(folder)
            
            if !FileManager.default.fileExists(atPath: folderPath.path) {
                structureProper = false
                break
            }
        }
        
        return folderExists && structureProper
    }
    
    // MARK: Helpers
    private func parseDeviceSupportString(_ string: String) -> (String?, Version, String)? {
        let splitted = string.split(separator: " ", maxSplits: 3, omittingEmptySubsequences: true)
        
        // we have device too
        if splitted.count == 3 {
            let device = String(splitted[0])
            let version = Version(describing: String(splitted[1]))
            let build = String(splitted[2])
            
            if let version = version {
                return (device, version, build)
            } else {
                log.warning("No version for device support: \(string), skipping")
            }
        }
        
        // no device so only version and build
        if splitted.count == 2 {
            let version = Version(describing: String(splitted[0]))
            let build = String(splitted[1])
            
            if let version = version {
                return (nil, version, build)
            } else {
                log.warning("No version for device support: \(string), skipping")
            }
        }
        
        return nil
    }
    
    private func parseSimulatorRuntime(_ string: String) -> (String, Version)? {
        let splitted = string.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        
        if splitted.count == 2 {
            let system = String(splitted[0])
            let systemVersion = Version(describing: String(splitted[1]))
            
            if let version = systemVersion {
                return (system, version)
            } else {
                log.warning("No version for simulator: \(string), skipping")
            }
        }
        
        return nil
    }
    
    private func parseDerivedDataProject(from location: URL) -> (String, URL)? {
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
                let projectRealUrl = URL(fileURLWithPath: projectRealPath)
                
                return (name, projectRealUrl)
            }
        }
        
        return nil
    }
    
    // MARK: Scan files
    public func scanFiles(in location: Location) {
        guard let entry = self.locations[location] else {
            precondition(self.locations.keys.contains(location), "❌ No entry found for location: \(location)")
            return
        }
        
        // scan and find files
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.scanWillBegin(for: location, entry: entry)
        }
        
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
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.scanDidFinish(for: location, entry: entry)
        }
        
        // check for those files sizes
        entry.recalculateSize()
        
        // TODO: add separate "check did finish notifications per entry?"
        DispatchQueue.main.async {  [weak self] in
            self?.delegate?.sizesCheckDidFinish(for: location, entry: entry)
        }
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
                for symbolUrl in symbols {
                    if let deviceSupport = self.parseDeviceSupportString(symbolUrl.lastPathComponent) {
                        let deviceSupportEntry = XcodeFileEntry(label: "\(deviceSupport.1) \(deviceSupport.2)")
                        deviceSupportEntry.addPath(path: symbolUrl)
                        
                        entry.entry.addChild(item: deviceSupportEntry)
                    }
                }
            } else {
                log.warning("Cannot check contents of '\(entryUrl)', skipping")
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
                if let simulatorRuntime = self.parseSimulatorRuntime(simulatorRuntimeUrl.deletingPathExtension().lastPathComponent) {
                    let simulatorEntry = XcodeFileEntry(label: "\(simulatorRuntime.0) \(simulatorRuntime.1)", selected: false)
                    simulatorEntry.addPath(path: simulatorRuntimeUrl)
                    
                    results.append(simulatorEntry)
                }
            }
        }
        
        // TODO: Scan for simulators (~/Library/Developer/CoreSimulator/Devices), or use `xcrun simctl delete unavailable` command if possible, but only after runtime deletion
        
        return results
    }
    
    private func scanArchivesLocations() -> [XcodeFileEntry] {
        return []
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
                
                if let projectData = self.parseDerivedDataProject(from: projectFolder) {
                    let projectEntry = XcodeFileEntry(label: "\(projectData.0) (\(projectData.1.path))", selected: true)
                    projectEntry.addPath(path: projectFolder)
                    
                    results.append(projectEntry)
                }
            }
        }
        
        return results
    }
}
