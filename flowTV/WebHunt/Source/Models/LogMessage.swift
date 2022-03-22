//
//  LogMessage.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/23.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Foundation
import os.log

enum LogLevel: String {
    case info, debug, warning, error
}

final class LogMessage {
    let date: Date
    let level: LogLevel
    let message: String
    var actionName: String?
    var actionBlock: BlockOperation?
    
    init(level: LogLevel, message: String) {
        self.level = level
        self.message = message
        self.date = Date()
    }
}

typealias LoggerCallback = (LogLevel) -> Void

final class Logger {
    static let sharedInstance = Logger()
    
    var callbacks = [LoggerCallback]()
    
    func addCallback(_ callback:@escaping LoggerCallback) {
        callbacks.append(callback)
    }
    
    func callBack(level: LogLevel) {
        DispatchQueue.main.async {
            for callback in self.callbacks {
                callback(level)
            }
        }
    }
}
var LogMessages = [LogMessage]()

// swiftlint:disable:next identifier_name
func Log(level: LogLevel, message: String) {
    LogMessages.append(LogMessage(level: level, message: message))
    
    // We throw errors to console, they always matter
    if level == .error {
        if #available(OSX 10.12, *) {
            // This is faster when available
            let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Screensaver")
            os_log("HunterError: %@", log: log, type: .error, message)
        } else {
            // Fallback on earlier versions
            NSLog("HunterError: \(message)")
        }
    }
    
    let preferences = Preferences.sharedInstance
    
    // We may callback
    if level == .warning || level == .error || (level == .debug && preferences.debugMode) {
        let logger = Logger.sharedInstance
        logger.callBack(level: level)
    }
    
    // We may log to disk, asyncly
    // Comment the firt if to always log to disk
    if preferences.logToDisk {
        DispatchQueue.main.async {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .medium
            let string = dateFormatter.string(from: Date()) + " \(level)" + " : " + message + "\n"
            
            if let cacheDirectory = WebCache.cacheDirectory {
                var cacheFileUrl = URL(fileURLWithPath: cacheDirectory as String)
                cacheFileUrl.appendPathComponent("hunter.log")
                
                let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                
                if FileManager.default.fileExists(atPath: cacheFileUrl.path) {
                    do {
                        let fileHandle = try FileHandle(forWritingTo: cacheFileUrl)
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    } catch {
                        print("Can't open handle")
                    }
                } else {
                    do {
                        try data.write(to: cacheFileUrl, options: .atomic)
                    } catch {
                        print("Can't write to file")
                    }
                }
            } else {
                NSLog("AerialError: No cache directory, this is super bad")
            }
        }
    }
}

func debugLog(_ message: String) {
    #if DEBUG
    print("\(message)\n")
    #endif
    
    // Comment the condition to always log debug mode
    let preferences = Preferences.sharedInstance
    if preferences.debugMode {
        Log(level: .debug, message: message)
    }
}

func infoLog(_ message: String) {
    Log(level: .info, message: message)
}

func warnLog(_ message: String) {
    Log(level: .warning, message: message)
}

func errorLog(_ message: String) {
    Log(level: .error, message: message)
}

func fileName(_ file: String) -> String {
    return (file as NSString).lastPathComponent
}
