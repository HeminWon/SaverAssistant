//
//  MEMWindowController.swift
//  Memories
//
//  Created by Hemin Won on 2019/5/3.
//  Copyright © 2019 Hemin Won. All rights reserved.
//

import Cocoa

class MEMWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    
    lazy var memWindow: NSWindow? = {
        let frame: CGRect = CGRect(x: 0, y: 0, width: NSScreen.main?.frame.size.width ?? 2560, height: NSScreen.main?.frame.size.height ?? 1600)
        let style: NSWindow.StyleMask = [.titled,.closable,.resizable]
        let back: NSWindow.BackingStoreType = .buffered
        let window: MEMWindow = MEMWindow(contentRect: frame, styleMask: style, backing: back, defer: false)
        //        window.isResizable = false
        window.title = "Memories Window"
        window.windowController = self
        //        window.titleVisibility = .hidden
        //        window.titlebarAppearsTransparent = true
        //        window.isMovableByWindowBackground = true
        //        window.backgroundColor = NSColor.red
        return window
    }()
    
    lazy var viewController: MEMViewController = {
        let viewController = MEMViewController()
        return viewController
    }()
    
    override init(window: NSWindow?) {
        super.init(window: window)
        self.window = self.memWindow
        self.contentViewController = self.viewController
        self.window?.center()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
