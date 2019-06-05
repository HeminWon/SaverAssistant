//
//  main.swift
//  IssueTrain
//
//  Created by HeminWon on 2018/7/22.
//  Copyright © 2018 HeminWon. All rights reserved.
//

import AppKit

func mainMenu() -> NSMenu {
    let    mainMenu             =    NSMenu()
    let    mainAppMenuItem      =    NSMenuItem(title: "Application", action: nil, keyEquivalent: "")
    let    mainFileMenuItem     =    NSMenuItem(title: "File", action: nil, keyEquivalent: "")
    mainMenu.addItem(mainAppMenuItem)
    mainMenu.addItem(mainFileMenuItem)
    
    let    appMenu              =    NSMenu()
    mainAppMenuItem.submenu     =    appMenu
    
    let    appServicesMenu      =    NSMenu()
    NSApp.servicesMenu          =    appServicesMenu
    appMenu.addItem(withTitle: "About", action: nil, keyEquivalent: "")
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Preferences...", action: nil, keyEquivalent: ",")
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Hide", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
    appMenu.addItem({ ()->NSMenuItem in
        let m = NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        m.keyEquivalentModifierMask = NSEvent.ModifierFlags([.command, .option])
        return m
        }())
    appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
    
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Services", action: nil, keyEquivalent: "").submenu    =    appServicesMenu
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    
    let    fileMenu             =    NSMenu(title: "File")
    mainFileMenuItem.submenu    =    fileMenu
    fileMenu.addItem(withTitle: "New...", action: #selector(NSDocumentController.newDocument(_:)), keyEquivalent: "n")
    
    return mainMenu
}

autoreleasepool { () -> () in
    let app = NSApplication.shared // 创建应用
    let delegate = AppDelegate()
    app.delegate = delegate // 配置应用代理
    app.mainMenu = mainMenu()
    app.run() // 启动应用
}
