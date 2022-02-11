//
//  URL+AcquireAccessFromSandbox.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 16.09.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Foundation
import Cocoa

//
// An article that tries to describe intricacies of sanbos file access:
// https://benscheirman.com/2019/10/troubleshooting-appkit-file-permissions/
//

extension URL {
    private struct SandboxFolderAccessError: Error {
        
    }
    
    public func acquireAccessFromSandbox(bookmark: Data? = nil, allowCancel: Bool = true, openPanelMessage: String = "Application needs permission to access this folder") -> URL? {
        func doWeHaveAccess(for url: URL) -> Bool {
            let fm = FileManager.default
            
            let isAccesible: Bool
            let _ = url.startAccessingSecurityScopedResource()
            isAccesible = fm.isReadableFile(atPath: url.path) && fm.isWritableFile(atPath: url.path)
            url.stopAccessingSecurityScopedResource()
            
            return isAccesible
        }
        
        // check if we already have access, then we don't need to show the dialog or use security bookmarks
        if doWeHaveAccess(for: self) {
            return self
        }
        
        // if we don't have access, so first try to load security bookmark
        if let bookmarkData = bookmark {
            do {
                var isBookmarkStale = false
                let bookmarkedUrl = try URL(resolvingBookmarkData: bookmarkData, options: [.withSecurityScope], bookmarkDataIsStale: &isBookmarkStale)
                
                if !isBookmarkStale {
                    if doWeHaveAccess(for: bookmarkedUrl) {
                        return bookmarkedUrl
                    } else {
                        log.warning("URL+AcquireAccessFromSandbox: Access denied after using bookmark but bookmark is not stale!")
                        throw SandboxFolderAccessError()
                    }
                } else {
                    // refresh bookmark as it's stale, it can happen on some system changes, updates etc.
                    if let bookmarkData = try? self.bookmarkData(options: [.withSecurityScope]) {
                        Preferences.shared.setFolderBookmark(bookmarkData: bookmarkData, for: self)
                        
                        return self.acquireAccessFromSandbox(bookmark: bookmarkData, allowCancel: allowCancel, openPanelMessage: openPanelMessage)
                    } else {
                        log.warning("URL+AcquireAccessFromSandbox: Bookmark was stale, but cannot refresh a bookmark for some reason!")
                        throw SandboxFolderAccessError()
                    }
                }
            } catch(let error) { // in case of stale bookmark or fail to get one, try again without it
                log.warning("URL+AcquireAccessFromSandbox: Failed to resolve bookmark: \(error.localizedDescription)")
                
                return self.acquireAccessFromSandbox(bookmark: nil, allowCancel: allowCancel, openPanelMessage: openPanelMessage)
            }
        }
        
        // well, so maybe first acquire the bookmark by opening open panel?
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = self
        openPanel.message = openPanelMessage
        openPanel.prompt = "Open"
        
        openPanel.allowedFileTypes = ["none"]
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseDirectories = true
        
        let openPanelResponse = openPanel.runModal()
        
        // check if we get proper file & save bookmark to it, if not, repeat
        if let folderUrl = openPanel.urls.first {
            if folderUrl != self {
                Alerts.infoAlert(title: "Can't get access to \(self.path) folder",
                               message: "Did you choose the right folder?",
                          okButtonText: "Repeat")
                
                return self.acquireAccessFromSandbox(bookmark: nil, allowCancel: allowCancel, openPanelMessage: openPanelMessage)
            }
            
            if doWeHaveAccess(for: folderUrl) {
                if let bookmarkData = try? folderUrl.bookmarkData(options: [.withSecurityScope]) {
                    Preferences.shared.setFolderBookmark(bookmarkData: bookmarkData, for: self)
                    
                    return folderUrl
                }
            } else {
                // well, we tried but we can't get access to this folder
                log.error("URL+AcquireAccessFromSandbox: Can't access folder after selecting it from Open panel, no access: \(self.path)")
                
                // delete folder bookmark just in case
                Preferences.shared.setFolderBookmark(bookmarkData: nil, for: self)
                
                return nil
            }
        } else {
            log.warning("URL+AcquireAccessFromSandbox: Didn't get folder from Open panel! Modal response: \(openPanelResponse)")
            
            // if we allow cancel, then legitimately return
            if allowCancel {
                return nil
            }
        }
        
        return self.acquireAccessFromSandbox(bookmark: nil, allowCancel: allowCancel, openPanelMessage: openPanelMessage)
    }
}
