//
//  FeedbackMailer.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 03/06/2021.
//  Copyright © 2021 One Minute Games. All rights reserved.
//

import Foundation
import IOKit
import Cocoa

public final class FeedbackMailer {
    // MARK: Properties
    public static let shared = FeedbackMailer()
    
    // MARK: Constants
    private static let feedbackMailBase64 = "a29ucmFkLmtvbGFrb3dza2lAbWUuY29t" // base64 encoded to avoid spam bots
    
    // MARK: System profile

    private func macModelIdentifier() -> String? {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?
        if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
            modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
        }

        IOObjectRelease(service)
        return modelIdentifier
    }
    
    private func prepareSystemProfileInfo() -> String {
        let fm = FileManager.default
        let appBundleInfoDict = Bundle.main.infoDictionary
        let appVersion = (appBundleInfoDict?["CFBundleShortVersionString"] as? String) ?? "-"
        let appBuildNumber = (appBundleInfoDict?["CFBundleVersion"] as? String) ?? "-"
        let osVersionInfo = ProcessInfo.processInfo.operatingSystemVersionString
        let osInfoString = "macOS \(osVersionInfo)"
        let macModelIdentifier = self.macModelIdentifier() ?? "-"
        let devFolderPath = Files.userDeveloperFolder.path
        let isDevFolderExists = XcodeFiles.isDeveloperFolderExists()
        let developerFolderReadable = fm.isReadableFile(atPath: devFolderPath)
        let developerFolderWriteable = fm.isWritableFile(atPath: devFolderPath)
        let customDerivedDataFolder = Preferences.shared.customDerivedDataFolder?.path ?? "-"
        let customArchivesFolder = Preferences.shared.customArchivesFolder?.path ?? "-"
        
        return """
            DevCleaner \(appVersion) (\(appBuildNumber))
            Does '~/Library/Developer' folder exists: \(isDevFolderExists ? "YES" : "NO")
            Can read '~/Library/Developer' folder: \(developerFolderReadable ? "YES" : "NO")
            Can write '~/Library/Developer' folder: \(developerFolderWriteable ? "YES" : "NO")
            
            Custom derived data folder: \(customDerivedDataFolder)
            Custom archives folder: \(customArchivesFolder)
            
            System: \(osInfoString)
            Mac model: \(macModelIdentifier)
            
            """
    }
    
    // MARK: Sending e-mails
    private func sendEmail(subject: String, body: String, attachments: [URL]) {
        guard let emailService = NSSharingService(named: .composeEmail) else {
            log.warning("FeedbackMailer: Can't create compose e-mail NSSharingService")
            return
        }
        
        guard let decodedEmailData = Data(base64Encoded: Self.feedbackMailBase64),
              let decodedEmail = String(data: decodedEmailData, encoding: .utf8) else {
            log.error("FeedbackMailer: Error while decoding support e-mail")
            return
        }
        
        var emailItems: [Any] = []
        emailItems.append(body)
        if !attachments.isEmpty { // for some reason it won't work if we have empty attachments array
            emailItems.append(contentsOf: attachments)
        }
        
        emailService.recipients = [decodedEmail]
        emailService.subject = subject
        
        if emailService.canPerform(withItems: emailItems) {
            emailService.perform(withItems: emailItems)
        } else {
            Alerts.infoAlert(title: "Can't send e-mail",
                             message: "It seems your system doesn't have e-mail configured. You can send your feedback manually to \(decodedEmail)")
        }
    }
    
    public func sendFeedback() {
        self.sendEmail(subject: "DevCleaner Feedback", body: "", attachments: [])
    }
    
    public func reportAnIssue() {
        // logs attachments
        var logAttachments: [URL] = []
        if let currentLogPath = log.logFilePath { logAttachments.append(currentLogPath) }
        if let oldLogPath = log.oldLogFilePath  { logAttachments.append(oldLogPath) }
        
        // some system informations
        let systemProfile = self.prepareSystemProfileInfo()
        
        let reportBody = """
            Write your report here
            
            =================================================
            
            \(systemProfile)
            """
        
        self.sendEmail(subject: "DevCleaner Issue Report", body: reportBody, attachments: logAttachments)
    }
}
