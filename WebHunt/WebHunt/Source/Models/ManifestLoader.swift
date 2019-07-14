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
    
    var callbacks = [ManifestLoadCallback]()
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
                if let subscribes = webHuntsubscribe() {
                    for subscribe in subscribes {
                        subscribeWebs(url: subscribe.url, remark: subscribe.remark)
                    }
                } else {
                    subscribeWebs(url: URL(string: "https://raw.githubusercontent.com/HeminWon/SaverAssistant/develop/WebHunt/Resources/hunt-original.yaml")!, remark: "hunter")
                }
            }
        }
        
    }
    
    func addCallback(_ callback:@escaping ManifestLoadCallback) {
        if !loadedManifest.isEmpty {
            callback(loadedManifest)
        } else {
            callbacks.append(callback)
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
        var cacheDirectory = WebCache.cacheDirectory!
        cacheDirectory.append(contentsOf: "/subscribe/")
        let urls = try? FileManager.default.contentsOfDirectory(atPath: cacheDirectory)
        
        return (urls != nil) ? true : false
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
    
    func webHuntsubscribe() -> [Subscriber]? {
        if let cacheDirectory = WebCache.cacheDirectory {
            let fileManager = FileManager.default
            
            var cacheResourcesString = cacheDirectory
            cacheResourcesString.append(contentsOf: "/" + "webHunt.yaml")
            
            if !fileManager.fileExists(atPath: cacheResourcesString) {
                return nil
            }
            
            let fileURL = URL(fileURLWithPath: cacheResourcesString)
            let subscrbes = readSubsribes(url: fileURL)
            return subscrbes
        }
        return nil
    }
    
    
    // Load the JSON Data cached on disk
    func loadCachedManifests() {
        if var cacheDirectory = WebCache.cacheDirectory {
            cacheDirectory.append(contentsOf: "/subscribe/")
            if FileManager.default.fileExists(atPath: cacheDirectory) {
                do {
                    let urls = try FileManager.default.contentsOfDirectory(atPath: cacheDirectory)
                    for url in urls {
                        let file = cacheDirectory.appending(url)
                        if let webs = readManifests(url: URL(fileURLWithPath: file)) {
                            loadedManifest += webs
                        }
                    }
                    loadedManifest = loadedManifest.sorted(by: { (HunterWeb0, HunterWeb1) -> Bool in
                        return HunterWeb0.url < HunterWeb1.url
                    })
                } catch {
                    
                }
                for callback in self.callbacks {
                    callback(self.loadedManifest)
                }
                self.callbacks.removeAll()
                
            }
        }
    }
    
    // MARK: - Subscribe
    func subscribeWebs(url: URL, remark: String) {
        
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
                guard var configs = map["subscribes" as Node] else {
                    return
                }
                let ele : Node = ["url": try Node(url), "remark": Node(remark)]
                configs.sequence?.append(ele)
                configs.sequence = Node.Sequence(configs.array().unique.filter({$0.mapping?["url" as Node]}))
                map[String("subscribes")] = configs
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
    
    func readSubsribes(url: URL) -> [Subscriber]? {
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        if let batch = readYaml(url) {
            guard let assets = batch["webProfiles"] as? [NSDictionary] else { return nil }
            var subscribes = [Subscriber]()
            for item in assets {
                guard let url = item["url"] as? String else {
                    continue
                }
                guard let remark = item["remark"] as? String else {
                    continue
                }
                if let subURL = URL(string: url) {
                    let sub = Subscriber(url: subURL, remark: remark)
                    subscribes.append(sub)
                }
            }
            return subscribes
        }
        return nil
    }
    
    func readManifests(url: URL) -> [HunterWeb]? {
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        if let batch = readYaml(url) {
            guard let assets = batch["webProfiles"] as? [NSDictionary] else { return nil }
            var processedWebs = [HunterWeb]()
            for item in assets {
                guard let url = item["url"] as? String else {
                    continue
                }
                let remark = item["remark"] as? String
                let group = item["group"] as? String
                let web = HunterWeb(url: url, remark: remark, group: group)
                processedWebs.append(web)
            }
            return processedWebs
        }
        return nil
    }
}
