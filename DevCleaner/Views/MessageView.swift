//
//  MessageView.swift
//  DevCleaner
//
//  Created by Konrad Kołakowski on 17.06.2018.
//  Copyright © 2018 One Minute Games. All rights reserved.
//

import Cocoa

public class MessageView: NSView {
    // MARK: Properties
    private let label = NSTextField()
    
    public var message: String = String() {
        didSet {
            self.label.stringValue = self.message
        }
    }
    
    public var backgroundColor: NSColor = .windowBackgroundColor {
        didSet {
            self.wantsLayer = true
            self.layer?.backgroundColor = self.backgroundColor.cgColor
        }
    }
    
    // MARK: Initialization & overrides
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // set background
        self.backgroundColor = NSColor.windowBackgroundColor
        
        // set message label
        self.label.font = NSFont.systemFont(ofSize: 17.0, weight: .bold)
        self.label.isEditable = false
        self.label.isSelectable = false
        self.label.drawsBackground = false
        self.label.isBordered = false
        self.label.isBezeled = false
        self.label.usesSingleLineMode = true
        self.label.alignment = .center
        
        self.addSubview(self.label)
    }
    
    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layout() {
        let targetHeight: CGFloat = 30.0
        self.label.frame = NSRect(x: 0.0, y: (self.frame.height - targetHeight) / 2.0,
                                  width: self.frame.width, height: targetHeight)
        
        super.layout()
    }
}
