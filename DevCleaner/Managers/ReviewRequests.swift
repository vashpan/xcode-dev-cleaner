//
//  ReviewRequests.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 31/08/2019.
//  Copyright © 2019 One Minute Games. All rights reserved.
//

import Foundation
import StoreKit

public final class ReviewRequests {
    // MARK: Properties
    public static let shared = ReviewRequests()
    
    // MARK: Constants
    private static let bytesNeededForReviewRequest: Int64 = 20 * 1024 * 1024 * 1024 // 20GB
    private static let cleansNeededForReviewRequest = 3
    
    // MARK: Showing review request
    public func requestReviewIfNeeded() {
        let totalBytesCleaned = Preferences.shared.totalBytesCleaned
        let totalCleansPerformedSinceLastRequest = Preferences.shared.cleansSinceLastReview
        
        // desired rules:
        // we show it either if we passed TOTAL of 20GB of cleaned bytes, which may be even on the first run of the app
        // or, if we clean smaller amounts, after 3 cleans
        // after we pass those 20GB total cleaned amount, we ask everytime we clean basically (limits according to system)
        if totalBytesCleaned > ReviewRequests.bytesNeededForReviewRequest || totalCleansPerformedSinceLastRequest >= ReviewRequests.cleansNeededForReviewRequest {
            // workaround due to an issue with presenting review popups in the background
            // https://furnacecreek.org/blog/2024-04-14-how-to-prevent-background-mac-app-store-rating-windows
            //
            if #available(macOS 14.0, *) {
                NSApp.yieldActivation(toApplicationWithBundleIdentifier: "com.apple.storeuid")
            }
            
            SKStoreReviewController.requestReview()
            
            Preferences.shared.cleansSinceLastReview = 0
        }
    }
    
    public func showReviewOnTheAppStore() {
        guard let appStoreUrl = URL(string: "macappstore://apps.apple.com/app/id1388020431?action=write-review") else {
            log.error("ReviewRequests: Can't make a review URL!")
            return
        }
        
        NSWorkspace.shared.open(appStoreUrl)
    }
}
