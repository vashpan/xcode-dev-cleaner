//
//  LoadingView.swift
//  XcodeCleaner
//
//  Created by Konrad Kołakowski on 05.06.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

public class LoadingView: NSView {
    // MARK: Properties
    private let progressIndicator = NSProgressIndicator()
    
    // MARK: Initialization & overrides
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // set background
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        // add loading indicator
        self.progressIndicator.style = .spinning
        self.progressIndicator.frame = frameRect
        
        self.addSubview(progressIndicator)
    }
    
    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layout() {
        self.progressIndicator.frame = self.frame
        
        super.layout()
    }
    
    public override func viewWillMove(toSuperview newSuperview: NSView?) {
        if newSuperview == nil {
            self.progressIndicator.stopAnimation(self)
        } else {
            self.progressIndicator.startAnimation(self)
        }
    }
}
