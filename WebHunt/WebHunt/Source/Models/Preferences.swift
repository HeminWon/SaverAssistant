//
//  Preferences.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/23.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Foundation
import ScreenSaver

final class Preferences {
    
    // MARK: - Types
    fileprivate enum Identifiers: String {
        case newDisplayMode = "newDisplayMode"
        case newViewingMode = "newViewingMode"
        case debugMode = "debugMode"
        case logToDisk = "logToDisk"
    }
    
    enum NewDisplayMode: Int {
        case allDisplays, mainOnly, secondaryOnly, selection
    }
    
    enum NewViewingMode: Int {
        case independent, mirrored, spanned
    }
    
    enum BetaCheckFrequency: Int {
        case hourly, bidaily, daily
    }
    
    enum NewVideosMode: Int {
        case weekly, monthly, never
    }
    
    static let sharedInstance = Preferences()
    
    lazy var userDefaults: UserDefaults = {
        let module = "com.heminwon.io.hunter"
        
        guard let userDefaults = ScreenSaverDefaults(forModuleWithName: module) else {
            warnLog("Couldn't create ScreenSaverDefaults, creating generic UserDefaults")
            return UserDefaults()
        }
        
        return userDefaults
    }()
    
    var newDisplayMode: Int? {
        get {
            return optionalValue(forIdentifier: .newDisplayMode)
        }
        set {
            setValue(forIdentifier: .newDisplayMode, value: newValue)
        }
    }
    
    var newViewingMode: Int? {
        get {
            return optionalValue(forIdentifier: .newViewingMode)
        }
        set {
            setValue(forIdentifier: .newViewingMode, value: newValue)
        }
    }
    
    init() {
        registerDefaultValues()
    }
    
    func registerDefaultValues() {
        var defaultValues = [Identifiers: Any]()
        defaultValues[.debugMode] = false
        defaultValues[.logToDisk] = true
        
        let defaults = defaultValues.reduce([String: Any]()) { (result, pair:(key: Identifiers, value: Any)) -> [String: Any] in
            var mutable = result
            mutable[pair.key.rawValue] = pair.value
            return mutable
        }
        userDefaults.register(defaults: defaults)
    }
    
    var debugMode: Bool {
        get {
            return value(forIdentifier: .debugMode)
        }
        set {
            setValue(forIdentifier: .debugMode, value: newValue)
        }
    }
    
    var logToDisk: Bool {
        get {
            return value(forIdentifier: .logToDisk)
        }
        set {
            setValue(forIdentifier: .logToDisk, value: newValue)
        }
    }
    
    // MARK: - Setting, Getting
    
    fileprivate func value(forIdentifier identifier: Identifiers) -> Bool {
        let key = identifier.rawValue
        return userDefaults.bool(forKey: key)
    }
    
    fileprivate func optionalValue(forIdentifier identifier: Identifiers) -> Int? {
        let key = identifier.rawValue
        return userDefaults.integer(forKey: key)
    }
    
    fileprivate func setValue(forIdentifier identifier: Identifiers, value: Any?) {
        let key = identifier.rawValue
        if value == nil {
            userDefaults.removeObject(forKey: key)
        } else {
            userDefaults.set(value, forKey: key)
        }
        synchronize()
    }
    
    func synchronize() {
        userDefaults.synchronize()
    }

}
