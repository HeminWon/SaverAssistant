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
                    subscribeWebs(url: URL(string: "https://raw.githubusercontent.com/HeminWon/homelab/master/m3u8/heminTV.m3u")!, remark: "hunter")
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
    
    func webHuntsubscribe() -> [Subscriber]? {
        if let cacheDirectory = WebCache.cacheDirectory {
            let fileManager = FileManager.default
            
            var cacheResourcesString = cacheDirectory
            cacheResourcesString.append(contentsOf: "/" + "heminTV.m3u")
            
            if !fileManager.fileExists(atPath: cacheResourcesString) {
                return nil
            }
            
            let fileURL = URL(fileURLWithPath: cacheResourcesString)
            guard let subscrbes = readSubsribes(url: fileURL) else {
                return nil
            }
            if subscrbes.isEmpty {
                return nil
            }
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
                        let file = URL(fileURLWithPath: cacheDirectory.appending(url))
                        if file.isM3U {
                            if let webs = readManifests(url: file) {
                                loadedManifest += webs
                            }
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
        if !url.isM3U {
            errorLog("need yaml file url")
            return
        }
        
        let downloadManager = DownloadManager()
        let completion = BlockOperation {
            self.loadCachedManifests()
        }
        let operation = downloadManager.queueDownload(url)
        completion.addDependency(operation)
        OperationQueue.main.addOperation(completion)
        
        let fileManager = FileManager.default
        
        let cacheDirectory = WebCache.cacheDirectory!
        if !fileManager.fileExists(atPath: cacheDirectory.appending("/heminTV.m3u")) {
            let webHuntURL = URL(fileURLWithPath:cacheDirectory.appending("/heminTV.m3u"))
            fileManager.createFile(atPath: webHuntURL.path, contents: nil, attributes: nil)
        }
        
        let webHuntURL = URL(fileURLWithPath:cacheDirectory.appending("/heminTV.m3u"))
        do {
            let file = try String(contentsOf: webHuntURL)
            let ele : Node = [Node("url"): try Node(url), Node("remark"): Node(remark)]
            guard var node = try Yams.compose(yaml: file) else {
                let node0 = [Node("subscribes"): [ele]]
                saveWebHunt(node0)
                return
            }
            guard var map = node.mapping else {
                node.mapping = [Node("subscribes"): [ele]]
                saveWebHunt(node)
                return
            }
            guard var subscribes = map["subscribes" as Node] else {
                map[String("subscribes")] = [ele]
                node.mapping = map
                saveWebHunt(node)
                return
            }
            subscribes.sequence?.append(ele)
            subscribes.sequence = Node.Sequence(subscribes.array().unique.filter({$0.mapping?["url" as Node]}).filter({($0.mapping?["remark"]?.string) != nil}).filter({($0.mapping?["url"]?.string) != nil}))
            map[String("subscribes")] = subscribes
            node.mapping = map
            
            let yaml = try Yams.dump(object:node, allowUnicode: true)
            try yaml.write(to: webHuntURL, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            errorLog("\(error)")
        }
    }
    
    func saveWebHunt(_ object: Any?) {
        let cacheDirectory = WebCache.cacheDirectory!
        let webHuntURL = URL(fileURLWithPath:cacheDirectory.appending("/heminTV.m3u"))
        do {
            let yaml = try Yams.dump(object:object, allowUnicode: true)
            try yaml.write(to: webHuntURL, atomically: true, encoding: String.Encoding.utf8)
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
        if !url.isFileURL {
            errorLog("need yaml file")
            return nil
        }
        
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
            guard let assets = batch["subscribes"] as? [NSDictionary] else { return nil }
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
                let timeInterval = item["timeInterval"] as? Int
                let timeExhibition = item["timeExhibition"] as? Int
                
                let web = HunterWeb(url: url, remark: remark, group: group)
                web.timeInterval = timeInterval ?? 0
                web.timeExhibition = timeExhibition ?? 0
                processedWebs.append(web)
            }
            return processedWebs
        }
        return nil
    }
}
