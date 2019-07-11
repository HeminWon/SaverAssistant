//
//  ManifestLoader.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/7.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Foundation
import Yams

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

typealias ManifestLoadCallback = ([HunterWeb]) -> Void

class ManifestLoader {
    static let instance: ManifestLoader = ManifestLoader()
    
    var loadedManifest = [HunterWeb]()
    
    var exhibitionList = [HunterWeb]()
    var lastExhibitionFromExhibitionList: HunterWeb?
    
    init() {
        if areManifestsFilesLoaded() {
            loadCachedManifests()
        } else {
            if areManifestsCached() {
                loadCachedManifests()
            } else {
                if !isManifestCached(manifest: .Original) {
                    
                    var urls: [URL] = []
                
                    urls.append(URL(string: "https://raw.githubusercontent.com/HeminWon/SaverAssistant/develop/WebHunt/Resources/hunt-original.yaml")!)

                    for url in urls {
                        subscribeWebs(url: url)
                    }
        
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
        if loadedManifest.count > 0 {
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
            cacheFileUrl.appendPathComponent("hunt-original.yaml")
            if let webs = readManifests(url: cacheFileUrl) {
                loadedManifest += webs
            }
        
            loadedManifest = loadedManifest.sorted(by: { (HunterWeb0, HunterWeb1) -> Bool in
                return HunterWeb0.url < HunterWeb1.url
            })
        }
    }
    
    // MARK: - Subscribe
    func subscribeWebs(url: URL) {
        
        let downloadManager = DownloadManager()
        let completion = BlockOperation {
            self.loadCachedManifests()
        }
        let operation = downloadManager.queueDownload(url)
        completion.addDependency(operation)
        OperationQueue.main.addOperation(completion)
        
        let fileManager = FileManager.default
        
        let cacheDirectory = WebCache.cacheDirectory!
        if !fileManager.fileExists(atPath: cacheDirectory.appending("/webHunt.yaml")) {
            let webHuntURL = URL(fileURLWithPath:cacheDirectory.appending("/webHunt.yaml"))
            fileManager.createFile(atPath: webHuntURL.path, contents: nil, attributes: nil)
        }
        
        let webHuntURL = URL(fileURLWithPath:cacheDirectory.appending("/webHunt.yaml"))
        do {
            let file = try String(contentsOf: webHuntURL)
            let webHunt = try Yams.compose(yaml: file)
            if var node = webHunt {
                var map = node.mapping!
                guard var configs = map["configs" as Node] else {
                    return
                }
                let ele : Node = ["url": try Node(url), "remarks": "node"]
                configs.sequence?.append(ele)
                configs.sequence = Node.Sequence(configs.array().unique.filter({$0.mapping?["url" as Node]}))
                map[String("configs")] = configs
                node.mapping = map
                
                let yaml = try Yams.dump(object:node, allowUnicode: true)
                try yaml.write(to: webHuntURL, atomically: true, encoding: String.Encoding.utf8)
            }
        } catch {
            errorLog("\(error)")
        }
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
    
    func readYaml(_ url: URL) -> NSDictionary? {
        let file = try? String(contentsOf: url)
        
        guard let yamlStr = file else {
            return nil;
        }
        let batches = try? Yams.load(yaml: yamlStr) as? [String: Any]
        
        guard let batch = batches else {
            return nil
        }
        return batch as NSDictionary
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
    
    func readManifests(url: URL) -> [HunterWeb]? {
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        if let batch = readYaml(url) {
            guard let assets = batch["assets"] as? [NSDictionary] else { return nil }
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
