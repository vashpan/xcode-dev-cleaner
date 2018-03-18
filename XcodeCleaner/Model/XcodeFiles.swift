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
    public let rootLocation: NSString
    public weak var delegate: XcodeFilesDelegate?
    
    public private(set) var locations: [Location : XcodeFileEntry]
    
    public static var defaultXcodeCachesLocation: String? {
        guard let librariesUrl = try? FileManager.default.url(for: .allLibrariesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        
        return librariesUrl.appendingPathComponent("Developer", isDirectory: true).path
    }
    
    // MARK: Initialization
    public init?(xcodeDevLocation: String) {
        guard XcodeFiles.checkIfLocationIsValid(location: xcodeDevLocation) else {
            return nil
        }
        
        self.rootLocation = xcodeDevLocation as NSString
        self.locations = [
            .deviceSupport: XcodeFileEntry(label: "Device Support", selected: true),
            .simulators: XcodeFileEntry(label: "Simulators", selected: false),
            .archives: XcodeFileEntry(label: "Archives", selected: false),
            .derivedData: XcodeFileEntry(label: "Derived Data", selected: true)
        ]
    }
    
    // MARK: Helpers
    private static func checkIfLocationIsValid(location: String) -> Bool {
        // check if folder exists
        let folderExists = FileManager.default.fileExists(atPath: location)
        
        // more checks, like folders structure
        var structureProper = true
        
        let foldersToCheck = ["Xcode", "CoreSimulator", "Shared/Documentation"]
        for folder in foldersToCheck {
            let nsStringLocation = location as NSString
            let folderPath = nsStringLocation.appendingPathComponent(folder)
            
            if !FileManager.default.fileExists(atPath: folderPath) {
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
                NSLog("⚠️ No version for device support: \(string), skipping")
            }
        }
        
        // no device so only version and build
        if splitted.count == 2 {
            let version = Version(describing: String(splitted[0]))
            let build = String(splitted[1])
            
            if let version = version {
                return (nil, version, build)
            } else {
                NSLog("⚠️ No version for device support: \(string), skipping")
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
        
        let xcodeLocation = self.rootLocation.appendingPathComponent("Xcode") as NSString
        var entries: [XcodeFileEntry] = []
        for entry in deviceSupportEntries {
            let entryPath = xcodeLocation.appendingPathComponent(entry.path) as NSString
            
            // scan for versions
            if let symbols = try? FileManager.default.contentsOfDirectory(atPath: entryPath as String) {
                for symbolPath in symbols {
                    let nsSymbolPath = symbolPath as NSString
                    let nsSymbolAbsolutePath = entryPath.appendingPathComponent(nsSymbolPath as String)
                    
                    if let deviceSupport = self.parseDeviceSupportString(nsSymbolPath.lastPathComponent) {
                        let deviceSupportEntry = XcodeFileEntry(label: "\(deviceSupport.1) \(deviceSupport.2)")
                        deviceSupportEntry.addPath(path: nsSymbolAbsolutePath)
                        
                        entry.entry.addChild(item: deviceSupportEntry)
                    }
                }
            } else {
                NSLog("⚠️ Cannot check contents of '\(entryPath)', skipping")
            }
            
            entries.append(entry.entry)
        }
        
        return entries
    }

    private func scanSimulatorsLocations() -> [XcodeFileEntry] {
        return []
    }
    
    private func scanArchivesLocations() -> [XcodeFileEntry] {
        return []
    }
    
    private func scanDerivedDataLocations() -> [XcodeFileEntry] {
        return []
    }
}
