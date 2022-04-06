//
//  WHWebPreferencesViewController.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/8.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Cocoa
import WebKit

class WHWebPreferencesViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var newDisplayModePopup: NSPopUpButton!
    @IBOutlet weak var newViewingModePopup: NSPopUpButton!
    
    lazy var preferences = Preferences.sharedInstance
    
    var webs: [HunterWeb]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        outlineView.floatsGroupRows = false
        outlineView.delegate = self
        outlineView.dataSource = self
        loadJSON()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }
    
    // MARK: - Manifest
    func loadJSON() {
        ManifestLoader.instance.addCallback { channels in
            self.loaded(channels: channels)
        }
    }
    
    func loaded(channels: [Channel]) {
        
        DispatchQueue.main.async {
            self.outlineView.reloadData()
            self.outlineView.expandItem(nil, expandChildren: true)
        }
    }
}

// MARK: -
extension WHWebPreferencesViewController {
    
    @IBAction func newDisplayModeAction(_ sender: NSPopUpButton) {
        debugLog("UI newDisplayModeClick: \(sender.indexOfSelectedItem)")
        preferences.newDisplayMode = sender.indexOfSelectedItem
        if preferences.newDisplayMode == Preferences.NewDisplayMode.selection.rawValue {
        } else {
        }
    }
    
    @IBAction func newViewingModeAction(_ sender: NSPopUpButton) {
        debugLog("UI newViewingModeClick: \(sender.indexOfSelectedItem)")
        preferences.newViewingMode = sender.indexOfSelectedItem
    }
}

// MARK: - Outline View Delegate & Data Source
extension WHWebPreferencesViewController {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return 1
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        switch item {
        case is Category:
            return true
        default:
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return "untitled"
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, dataCellFor tableColumn: NSTableColumn?, item: Any) -> NSCell? {
        let row = outlineView.row(forItem: item)
        return tableColumn!.dataCell(forRow: row) as? NSCell
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 10
    }
    
    func outlineView(_ outlineView: NSOutlineView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
        return 0
    }
}
