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
        case multiMonitorMode = "multiMonitorMode"
    }
    
    enum MultiMonitorMode: Int {
        case mainOnly, mirrored, independant, secondaryOnly
    }

    static let sharedInstance = Preferences()
    
    lazy var userDefaults: UserDefaults = {
        let module = "com.heminwon.io.hunter"
        
        guard let userDefaults = ScreenSaverDefaults(forModuleWithName: module) else {
            return UserDefaults()
        }
        
        return userDefaults
    }()
    
    var multiMonitorMode: Int? {
        get {
            return optionalValue(forIdentifier: .multiMonitorMode)
        }
        set {
            setValue(forIdentifier: .multiMonitorMode, value: newValue)
        }
    }
    
    init() {
//        registerDefaultValues()
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
