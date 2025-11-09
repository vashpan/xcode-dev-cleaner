//
//  AppleDevices.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 09/11/2025.
//  Copyright © 2025 One Minute Games. All rights reserved.
//

import Foundation
import TabularData

public struct AppleDevices {
    // MARK: Properties
    private static var deviceIdentifiersFile: URL? {
        let resourceName = "device_identifiers"
        
        if let url = Bundle.main.url(forResource: resourceName, withExtension: "csv") {
            return url
        }
        
        return Bundle.main.url(forResource: resourceName, withExtension: "csv")
    }
    
    private static let lookupTable: [String: String] = {
        guard let csvURL = Self.deviceIdentifiersFile else {
            log.warning("AppleDevices: device_identifiers.csv missing in bundle.")
            return [:]
        }
        
        do {
            let options = CSVReadingOptions(hasHeaderRow: true)
            let dataFrame = try DataFrame(contentsOfCSVFile: csvURL, options: options)
            var table: [String: String] = [:]
            
            for row in dataFrame.rows {
                guard let identifier = row["identifier"] as? String else {
                    continue
                }
                let name = (row["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
                table[identifier] = name?.isEmpty == false ? name : identifier
            }
            
            return table
        } catch {
            log.error("AppleDevices: Unable to load device_identifiers.csv: \(error)")
            return [:]
        }
    }()
    
    // MARK: Fetch device name
    public static func deviceName(for deviceId: String) -> String {
        guard !deviceId.isEmpty else {
            return "Unknown Device"
        }
        
        return Self.lookupTable[deviceId] ?? deviceId
    }
}

