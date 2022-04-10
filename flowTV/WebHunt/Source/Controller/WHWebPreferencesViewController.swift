//
//  WHWebPreferencesViewController.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/8.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Cocoa
import WebKit

extension NSTextField {
    override open func performKeyEquivalent(with event: NSEvent) -> Bool {
        let modifierkeys = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let key = event.characters ?? ""
        /// 点击 esc 取消焦点
        if modifierkeys.rawValue == 0 && key == "\u{1B}" {
            self.window?.makeFirstResponder(nil)
        }
        // command + shift + z 还原
        if modifierkeys == [.command, .shift] && key == "z" {
            self.window?.firstResponder?.undoManager?.redo()
            return true
        }
        if modifierkeys != .command {
            return super.performKeyEquivalent(with: event)
        }
        switch key {
        case "a":  // 撤消
            return NSApp.sendAction(#selector(NSText.selectAll(_:)), to: self.window?.firstResponder, from: self)
        case "c":  // 复制
            return NSApp.sendAction(#selector(NSText.copy(_:)), to: self.window?.firstResponder, from: self)
        case "v":  // 粘贴
            return NSApp.sendAction(#selector(NSText.paste(_:)), to: self.window?.firstResponder, from: self)
        case "x":  // 剪切
            return NSApp.sendAction(#selector(NSText.cut(_:)), to: self.window?.firstResponder, from: self)
        case "z":  // 撤消
            self.window?.firstResponder?.undoManager?.undo()
            return true
        default:
            return super.performKeyEquivalent(with: event)
        }
    }
}

class WHWebPreferencesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var newDisplayModePopup: NSPopUpButton!
    @IBOutlet weak var newViewingModePopup: NSPopUpButton!
    @IBOutlet weak var loadBtn: NSButton!
    
    lazy var preferences = Preferences.sharedInstance
    
    var channels : [Channel]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.tableView.floatsGroupRows = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.textField.maximumNumberOfLines = 1
        self.textField.stringValue = ManifestLoader.instance.subscribeURL?.absoluteString ?? ""
        loadJSON()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }
    
    // MARK: - Manifest
    func loadJSON() {
        ManifestLoader.instance.addCallback { channels in
            self.channels = channels
            self.loaded(channels: channels)
        }
    }
    
    func loaded(channels: [Channel]) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: -
extension WHWebPreferencesViewController {
    @IBAction func loadAction(_ sender: NSButton) {
        self.tableView.reloadData()
        self.loadJSON()
    }
    
    @IBAction func urlTextFiled(_ sender: NSTextFieldCell) {
        ManifestLoader.instance.subscribeURL = URL(string: sender.stringValue)
    }
    
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
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.channels?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        return "testtesttest"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // get the NSTableCellView for the column
        let result : NSTableCellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView

        switch tableColumn?.identifier.rawValue {
        case "AutomaticTableColumnIdentifier.0":
            result.textField?.stringValue = (self.channels?[row].name)!
            break
        case "AutomaticTableColumnIdentifier.1":
            result.textField?.stringValue = (self.channels?[row].url)!
            break
        default: break
        }
        return result
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if let rowView = tableView.makeView(withIdentifier: .ruleRowView, owner: self) as? NSTableRowView {
            return rowView
        }

        let rowView = NSTableRowView(frame: .zero)
        rowView.identifier = .ruleRowView
        return rowView
    }
}

private extension NSUserInterfaceItemIdentifier {
    static let ruleRowView = NSUserInterfaceItemIdentifier(rawValue: "RuleRowView")
}
