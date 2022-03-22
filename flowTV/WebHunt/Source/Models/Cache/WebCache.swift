//
//  WebCache.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/7.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Foundation

private struct Constants {
    static let defaultCacheDirectory = "WebHunt"
}

final class WebCache {
    
    static var computedCacheDirectory: String?
    
    static var cacheDirectory: String? {
        var cacheDirectory: String?
        
        if cacheDirectory == nil {
            let localCachePaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                      .localDomainMask,
                                                                      true)
            let userCachePaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                     .userDomainMask,
                                                                     true)
            if localCachePaths.isEmpty || userCachePaths.isEmpty {
                return nil
            }
            
            let localCacheDirectory = localCachePaths[0] as NSString
            let userCacheDirectory = userCachePaths[0] as NSString
        
            if webHuntCacheExists(at: localCacheDirectory) {
                cacheDirectory = localCacheDirectory.appendingPathComponent(Constants.defaultCacheDirectory)
            } else if webHuntCacheExists(at: userCacheDirectory) {
                cacheDirectory = userCacheDirectory.appendingPathComponent(Constants.defaultCacheDirectory)
            } else {
                // We create in local cache directory (/Library/Caches)
                cacheDirectory = localCacheDirectory.appendingPathComponent(Constants.defaultCacheDirectory)
                
                let fileManager = FileManager.default
                var didCreate = true
                if fileManager.fileExists(atPath: cacheDirectory!) == false {
                    do {
                        try fileManager.createDirectory(atPath: cacheDirectory!,
                                                        withIntermediateDirectories: false, attributes: nil)
                    } catch let error {
                        didCreate = false
                    }
                }
                
                if !didCreate {
                    // Last ditch effort, probably the user has some restriction on its account,
                    // so we try creating in its user directory as a fallback
                    cacheDirectory = userCacheDirectory.appendingPathComponent(Constants.defaultCacheDirectory)
                    
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: cacheDirectory!) == false {
                        do {
                            try fileManager.createDirectory(atPath: cacheDirectory!,
                                                            withIntermediateDirectories: false, attributes: nil)
                        } catch let error {
                            return nil
                        }
                    }
                }
            }
        }
        // Cache the computed value
        computedCacheDirectory = cacheDirectory
        return cacheDirectory
    }
    
    static func webHuntCacheExists(at: NSString) -> Bool {
        let webHuntCache = at.appendingPathComponent(Constants.defaultCacheDirectory)
        if FileManager.default.fileExists(atPath: webHuntCache as String) {
            return true
        } else {
            return false
        }
    }
}
