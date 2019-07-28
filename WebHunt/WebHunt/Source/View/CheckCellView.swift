//
//  CheckCellView.swift
//  WebHunt
//
//  Created by 王明海 on 2019/6/18.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Cocoa

class CheckCellView: NSTableCellView {

    @IBOutlet weak var checkButton: NSButton!
    @IBOutlet weak var mainTextField: NSTextField!
    @IBOutlet weak var secondTextField: NSTextField!
    @IBOutlet weak var thirdTextField: NSTextField!
    @IBOutlet weak var detailTextField: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
