//
//  MemoriesTrainView.swift
//  MemoriesTrain
//
//  Created by Hemin Won on 2019/5/3.
//  Copyright © 2019 Hemin Won. All rights reserved.
//

import Cocoa
import ScreenSaver

class MemoriesTrainView: ScreenSaverView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.white.setFill()
        bounds.fill()
        
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
