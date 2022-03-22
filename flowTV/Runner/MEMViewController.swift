//
//  MEMViewController.swift
//  Memories
//
//  Created by Hemin Won on 2019/5/3.
//  Copyright © 2019 Hemin Won. All rights reserved.
//

import Cocoa

class MEMViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    lazy var memView: MEMView = {
        let frame: CGRect = CGRect(x: 0, y: 0, width: (NSScreen.main?.frame.size.width ?? 2560) * 0.75, height: (NSScreen.main?.frame.size.height ?? 1600) * 0.75 )
        let view: MEMView = MEMView(frame: frame)
        return view
    }()
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.view = self.memView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
