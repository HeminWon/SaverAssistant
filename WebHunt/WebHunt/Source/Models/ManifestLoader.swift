//
//  ManifestLoader.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/7.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Foundation

typealias ManifestLoadCallback = ([HunterWeb]) -> Void

class ManifestLoader {
    static let instance: ManifestLoader = ManifestLoader()
    
    var loadedManifest = [HunterWeb]()
    
    var exhibitionList = [HunterWeb]()
    var lastExhibitionFromExhibitionList: HunterWeb?
    
    
    var manifestWebData: Data?
    
    init() {
        if areManifestsFilesLoaded() {
            loadManifestsFromLoadedFiles()
        } else {
            if areManifestsCached() {
                loadCachedManifests()
            } else {
                if !isManifestCached(manifest: .Original) {
                
                    let downloadManager = DownloadManager()
                    
                    var urls: [URL] = []
                
                    urls.append(URL(string: "https://raw.githubusercontent.com/HeminWon/SaverAssistant/master/WebHunt/Resources/hunt-original.json")!)
                    
                    let completion = BlockOperation {
                        // We can now load from the newly cached files
                        self.loadCachedManifests()
                        
                    }
                    
                    for url in urls {
                        let operation = downloadManager.queueDownload(url)
                        completion.addDependency(operation)
                    }
                    
                    OperationQueue.main.addOperation(completion)
                }
                
            }
        }
        
    }
    
    func addCallback(_ callback:@escaping ManifestLoadCallback) {
        if !loadedManifest.isEmpty {
            callback(loadedManifest)
        } else {
//            callbacks.append(callback)
        }
    }
    
    // MARK: - Manifests
    
    // Check if the Manifests have been loaded in this class already
    func areManifestsFilesLoaded() -> Bool {
        if manifestWebData != nil {
            return true
        } else {
            return false
        }
    }
    
    // Check if the Manifests are saved in our cache directory
    func areManifestsCached() -> Bool {
        return isManifestCached(manifest: .Original)
    }

    func isManifestCached(manifest: Manifests) -> Bool {
        if let cacheDirectory = WebCache.cacheDirectory {
            let fileManager = FileManager.default
            
            var cacheResourcesString = cacheDirectory
            cacheResourcesString.append(contentsOf: "/" + manifest.rawValue)
            
            if !fileManager.fileExists(atPath: cacheResourcesString) {
                return false
            }
        } else {
            return false
        }
        
        return true
    }
    
    // Load the JSON Data cached on disk
    func loadCachedManifests() {
        if let cacheDirectory = WebCache.cacheDirectory {
            var cacheFileUrl = URL(fileURLWithPath: cacheDirectory as String)
            cacheFileUrl.appendPathComponent("hunt-original.json")
            do {
                let ndata = try Data(contentsOf: cacheFileUrl)
                manifestWebData = ndata
            } catch {
            }
            
            if manifestWebData != nil {
                loadManifestsFromLoadedFiles()
            } else {
                // No internet, no anything, nothing to do
            }
        }
    }
    
    // Load Manifests from the saved preferences
    func loadManifestsFromLoadedFiles() {
        // Reset our array
        guard let data = manifestWebData else {
            return
        }
        
        var processedWebs = readManifestsConfig(data)!
        
        processedWebs = processedWebs.sorted { (HunterWeb0, HunterWeb1) -> Bool in
            return HunterWeb0.url < HunterWeb1.url
        }
        
        self.loadedManifest = processedWebs
    }
    
    // MARK: - Playlist generation
    func generateExhibitionList() {
        exhibitionList = [HunterWeb]()
        
        // Start with a shuffled list
        let shuffled = loadedManifest.shuffled()
        
        for web in shuffled {
            
            // ...
            exhibitionList.append(web)
        }
        // On regenerating a new playlist, we try to avoid repeating
        if let lastExhibition = lastExhibitionFromExhibitionList {
            if exhibitionList.count > 1 {
                exhibitionList = exhibitionList.filter{$0.url != lastExhibition.url}
            }
        }
        exhibitionList.shuffle()
    }
    
    func randomWeb(excluding: [HunterWeb]) -> HunterWeb? {
        if exhibitionList.isEmpty {
            generateExhibitionList()
        }
        
        if !exhibitionList.isEmpty {
            return exhibitionList.removeFirst()
        }
        return findBestEffortWeb()
    }
    
    func findBestEffortWeb() -> HunterWeb? {
        let shuffled = loadedManifest.shuffled()
        if shuffled.isEmpty {
            return nil
        }
        return shuffled.first
    }
    
    // MARK: - JSON
    func readJSONFromData(_ data: Data) -> NSDictionary? {
        let options = JSONSerialization.ReadingOptions.allowFragments
        let batches = try? JSONSerialization.jsonObject(with: data, options: options) as? NSDictionary

        guard let batch = batches else {
            return nil
        }
        return batch
    }
    
    func readManifestsConfig(_ data: Data) -> [HunterWeb]? {
        if let batch = readJSONFromData(data) {
            let assets = batch["assets"] as! [NSDictionary]
            var processedWebs = [HunterWeb]()
            for item in assets {
                let url = item["url"] as! String
                let description = item["description"] as! String
                let type = item["type"] as! String
                
                if !url.hasPrefix("http") {
                    continue
                }
                let web = HunterWeb(url: url, description: description, type: type)
                processedWebs.append(web)
            }
            return processedWebs
        }
        return nil
    }
}
