//
//  LoadingView.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 05.06.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

public class LoadingView: NSView {
    // MARK: Properties
    private let progressIndicator = NSProgressIndicator()
    
    // MARK: Constants
    private let indicatorSize: CGFloat = 32.0
    
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
        self.progressIndicator.controlSize = .regular
        self.progressIndicator.frame = self.indicatorFrame(size: indicatorSize, in: frameRect)
        
        self.addSubview(progressIndicator)
    }
    
    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layout() {
        self.progressIndicator.frame = self.indicatorFrame(size: indicatorSize, in: self.frame)
        
        super.layout()
    }
    
    public override func viewWillMove(toSuperview newSuperview: NSView?) {
        if newSuperview == nil {
            self.progressIndicator.stopAnimation(self)
        } else {
            self.progressIndicator.startAnimation(self)
        }
    }
    
    // MARK: Helpers
    private func indicatorFrame(size: CGFloat, in frameRect: CGRect) -> CGRect {
        return CGRect(x: (frameRect.width - size) / 2.0, y: (frameRect.height - size) / 2.0,
                      width: size, height: size)
    }
}
