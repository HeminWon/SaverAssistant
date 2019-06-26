//
//  HTAdvancedViewController.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/23.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Cocoa
import Foundation

class HTAdvancedViewController: NSViewController {

    @IBOutlet weak var showLogsBtn: NSButton!
    @IBOutlet weak var revealLogsFileBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
//        self.showLogsBtn.action = #selector(logsBtnAction)
    }
    
    @IBAction func logsBtnAction(_ sender: NSButton) {
        let shell = "open /Library/Caches/WebHunt/hunter.log"
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", shell]
        
        task.launch()
    }
}
