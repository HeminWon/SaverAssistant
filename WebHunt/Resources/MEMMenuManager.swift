//
//  MEMMenuManager.swift
//  Runner
//
//  Created by Hemin Won on 2019/6/4.
//  Copyright © 2019 Burns5. All rights reserved.
//

import Cocoa

class MEMMenuManager: NSObject {
    static let shared = MEMMenuManager()
//    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    private var captureItem = NSMenuItem()
    
    func configure() {
//        if let button = statusItem.button {
//            button.image = NSImage(named: NSImage.Name(rawValue: "MenuIcon"))
//        }
//
//        captureItem = NSMenuItem(title: LocalizedString.Capture.value, action: #selector(AppDelegate.capture), keyEquivalent: HotKeyManager.shared.captureKeyCombo.characters.lowercased())
//        captureItem.keyEquivalentModifierMask = KeyTransformer.cocoaFlags(from: HotKeyManager.shared.captureKeyCombo.modifiers)
//
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About", action: #selector(AppDelegate.openAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
//        menu.addItem(NSMenuItem(title: LocalizedString.Preference.value, action: #selector(AppDelegate.openPreferences), keyEquivalent: ","))
//        menu.addItem(withTitle: LocalizedString.CheckForUpdates.value,
//                     action: #selector(SUUpdater.checkForUpdates(_:)),
//                     target: SUUpdater.shared())
        menu.addItem(NSMenuItem.separator())
//        menu.addItem(captureItem)
        menu.addItem(NSMenuItem.separator())
//        menu.addItem(NSMenuItem(title: LocalizedString.QuitFuwari.value, action: #selector(AppDelegate.quit), keyEquivalent: "q"))
//
        NSApplication.shared.mainMenu = menu
    }
    
//    func udpateCpatureMenuItem() {
//        captureItem.keyEquivalent = HotKeyManager.shared.captureKeyCombo.characters.lowercased()
//        captureItem.keyEquivalentModifierMask = KeyTransformer.cocoaFlags(from: HotKeyManager.shared.captureKeyCombo.modifiers)
//    }
}
