//
//  ManifestLoader.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/7.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Foundation
import AppKit

extension Array where Element:Hashable {
    var unique:[Element] {
        var uniq = Set<Element>()
        uniq.reserveCapacity(self.count)
        return self.filter {
            return uniq.insert($0).inserted
        }
    }
    
    func filter<E: Equatable>(_ unique: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = unique(value)
            if !result.map({unique($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}

extension URL {
    var isM3U: Bool {
        get {
            let fileExt = self.pathExtension
            if fileExt == "m3u" || fileExt == "m3u8" {
                return true
            }
            return false
        }
    }
}

typealias ManifestLoadCallback = ([Channel]) -> Void

class ManifestLoader {
    static let instance: ManifestLoader = ManifestLoader()
    
    fileprivate var _subscribeURL: URL?
    
    var subscribeURL: URL? {
        set {
            _subscribeURL = newValue
            UserDefaults.standard.set(_subscribeURL, forKey: "subscribeURL")
            UserDefaults.standard.synchronize()
        }
        get {
            return _subscribeURL ?? UserDefaults.standard.url(forKey: "subscribeURL")
        }
    }
    
    var callbacks = [ManifestLoadCallback]()
    var loadedManifest = [Channel]()
    
    init() {
    }
    
    
    func addCallback(_ callback:@escaping ManifestLoadCallback) {
        if self.areManifestsFilesLoaded() {
            callback(loadedManifest)
        } else {
            callbacks.append(callback)
            self.load()
        }
    }

    // Check if the Manifests have been loaded in this class already
    func areManifestsFilesLoaded() -> Bool {
        if loadedManifest.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    // Check if the Manifests are saved in our cache directory
    func areManifestsCached() -> Bool {
        var cacheDirectory = WebCache.cacheDirectory!
        cacheDirectory.append(contentsOf: "/subscribe/")
        do {
            let urls = try FileManager.default.contentsOfDirectory(atPath: cacheDirectory)
            let legalfiles = urls.filter({ (url) -> Bool in
                if let file = URL(string: url) {
                    if file.isM3U {
                        return true
                    }
                }
                return false
            })
            return (legalfiles.isEmpty) ? false : true
        } catch {
        }
        return false
    }

    func isManifestCached(manifest: String) -> Bool {
        if let cacheDirectory = WebCache.cacheDirectory {
            let fileManager = FileManager.default
            
            var cacheResourcesString = cacheDirectory
            cacheResourcesString.append(contentsOf: "/" + manifest)
            
            if !fileManager.fileExists(atPath: cacheResourcesString) {
                return false
            }
        } else {
            return false
        }
        
        return true
    }
    
    func downloadM3U(_ url: URL,callback:@escaping () -> Void) {
        if !url.isM3U {
            errorLog("need yaml file url")
            return
        }
        
        let downloadManager = DownloadManager()
        let completion = BlockOperation {
            callback()
        }
        let operation = downloadManager.queueDownload(url)
        completion.addDependency(operation)
        OperationQueue.main.addOperation(completion)
    }

    
    func load() {
        if areManifestsCached() {
            loadCachedManifests()
        } else {
            if let url = self.subscribeURL {
                self.downloadM3U(url) {
                    self.loadCachedManifests()
                }
            }
        }
    }
    
    // Load the JSON Data cached on disk
    func loadCachedManifests() {
        if var cacheDirectory = WebCache.cacheDirectory {
            cacheDirectory.append(contentsOf: "/subscribe/")
            if FileManager.default.fileExists(atPath: cacheDirectory) {
                do {
                    let urls = try FileManager.default.contentsOfDirectory(atPath: cacheDirectory)
                    for url in urls {
                        let file = URL(fileURLWithPath: cacheDirectory.appending(url))
                        if file.isM3U {
                            let channels = self.readM3U(file)
                            self.loadedManifest = channels!
                            for callback in self.callbacks {
                                callback(self.loadedManifest)
                            }
                            self.callbacks.removeAll()
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
    
    // MARK: - JSON
    func readM3U(_ url: URL) -> [Channel]? {
        if !url.isFileURL {
            errorLog("need yaml file")
            return nil
        }
        
        let file = try? String(contentsOf: url)
        
        guard let yamlStr = file else {
            return nil;
        }

        let channels = try? M3U.load(m3u: yamlStr)
        return channels
    }
}
