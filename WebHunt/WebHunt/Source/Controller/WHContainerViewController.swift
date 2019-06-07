//
//  WHContainerViewController.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/2.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Cocoa

class WHContainerViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    @IBAction func colseBtn(_ sender: NSButton) {
//        NSApplication.shared.terminate(nil)
//        self.parent?.view.window?.endSheet(self.view.window!)
        self.view.window?.sheetParent?.endSheet(self.view.window!)
    }
    
}
