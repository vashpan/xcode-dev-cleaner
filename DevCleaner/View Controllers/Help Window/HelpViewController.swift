//
//  HelpViewController.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 07/09/2019.
//  Copyright © 2019 One Minute Games. All rights reserved.
//

import Cocoa
import WebKit

final class HelpViewController: NSViewController {
    // MARK: Properties & outlets
    @IBOutlet private weak var helpWebView: WKWebView!
    
    // MARK: Initialization & overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // load manual HTML
        guard let helpUrl = Bundle.main.url(forResource: "manual", withExtension: "html", subdirectory: "Manual") else {
            log.error("HelpViewController: Can't find manual HTML file!")
            return
        }
        
        self.helpWebView.loadFileURL(helpUrl, allowingReadAccessTo: helpUrl.deletingLastPathComponent())
    }
}
