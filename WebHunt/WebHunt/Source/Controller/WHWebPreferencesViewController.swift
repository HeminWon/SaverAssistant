//
//  WHWebPreferencesViewController.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/8.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Cocoa
import WebKit

final class Category {
    let type: String

    var webs: [HunterWeb] = [HunterWeb]()
    
    
    init(type: String) {
        self.type = type
    }
    
    func addWeb(web: HunterWeb) {
        webs.append(web)
    }
}

class WHWebPreferencesViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var newDisplayModePopup: NSPopUpButton!
    @IBOutlet weak var newViewingModePopup: NSPopUpButton!
    
    lazy var preferences = Preferences.sharedInstance
    
    var webs: [HunterWeb]?
    var categories = [Category]()
    
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
        ManifestLoader.instance.addCallback { (manifestWebs) in
            self.loaded(manifestWebs: manifestWebs)
        }
    }
    
    func loaded(manifestWebs: [HunterWeb]) {
        var webs = [HunterWeb]()
        var categories = [String: Category]()
        
        for web in manifestWebs {
            let type = web.group!
            if categories.keys.contains(type) == false {
                categories[type] = Category(type: type)
            }
            let category = categories[type]!
            category.addWeb(web: web)
            webs.append(web)
        }
        self.webs = webs
        
        let unsortedCategories = categories.values
        let sortedCategories = unsortedCategories.sorted { (category0, category1) -> Bool in
            return category0.type < category1.type
        }
        self.categories = sortedCategories
        
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
        guard item != nil else { return categories.count }
        switch item {
        case let category as Category:
            return category.webs.count
        default:
            return 1
        }
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
        guard let item = item else { return categories[index] }
        
        switch item {
        case let category as Category:
            return category.webs[index]
        default:
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        switch item {
        case let category as Category:
            return category.type
        case let web as HunterWeb:
            return web.url
        default:
            return "untitled"
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, dataCellFor tableColumn: NSTableColumn?, item: Any) -> NSCell? {
        let row = outlineView.row(forItem: item)
        return tableColumn!.dataCell(forRow: row) as? NSCell
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        switch item {
        case is Category:
            return true
        default:
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        switch item {
        case let category as Category:
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"),
                                            owner: nil) as! NSTableCellView
            view.textField?.stringValue = category.type
            
            return view
        case let web as HunterWeb:
            let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CheckCell"),
                                            owner: nil) as! CheckCellView
            // Mark the new view for this video for subsequent callbacks
            view.mainTextField?.stringValue = web.url
            view.secondTextField?.stringValue = String(web.timeInterval)
            view.thirdTextField?.stringValue = String(web.timeExhibition)
            view.detailTextField?.stringValue = web.remark ?? ""
            return view
        default:
            return nil
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        switch item {
        case _ as HunterWeb:
            return true
        default:
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        switch item {
        case let web as HunterWeb:
            if (web.remark != nil && web.remark != "") {
                return 48
            }
            return 19
        case is Category:
            return 17
        default:
            fatalError("unhandled item in heightOfRowByItem for \(item)")
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
        return 0
    }
}
