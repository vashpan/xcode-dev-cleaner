//
//  ArchiveFileEntry.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 27.03.2018.
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

import Foundation

public final class ArchiveFileEntry: XcodeFileEntry {
    // MARK: Types
    public enum SubmissionStatus {
        case success, failure, undefined
        
        fileprivate var glyph: String {
            switch self {
                case .success: return "✅"
                case .failure: return "❌"
                case .undefined: return String()
            }
        }
    }
    
    // MARK: Properties
    public let projectName: String
    public let bundleName: String
    public let version: Version
    public let build: String
    public let date: Date
    public let submissionStatus: SubmissionStatus
    
    public override var fullDescription: String {
        return "\(projectName) \(self.version.description) (\(self.build)) (\(self.extraInfo))"
    }
    
    // MARK: Initialization
    public init(projectName: String, bundleName: String, version: Version, build: String, date: Date, submissionStatus: SubmissionStatus, location: URL, selected: Bool) {
        self.projectName = projectName
        self.bundleName = bundleName
        self.version = version
        self.build = build
        self.date = date
        self.submissionStatus = submissionStatus
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let dateString = dateFormatter.string(from: self.date)
        
        super.init(label: "\(self.version.description) (\(self.build)) \(submissionStatus.glyph)", extraInfo: dateString, icon: nil, tooltip: true, selected: selected)
        
        self.addPath(path: location)
    }
}
