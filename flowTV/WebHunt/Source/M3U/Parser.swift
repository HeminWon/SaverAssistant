//
//  Parser.swift
//  WebHunt
//
//  Created by Hemin Won on 2022/4/5.
//  Copyright © 2022 HeminWon. All rights reserved.
//

import Foundation

public func load(m3u: String) throws -> [Any]? {
    return try Parser.init(m3u:m3u).singleRoot()
}

public final class Parser {
    public let m3u: String
    
    public struct Channel {
        public var name : String?
        public var prop : [String: String]?
        public var url : String?
    }
    
    var listach = [Channel]()
    
    public init(m3u string: String) throws {
        m3u = string
    }
    
    public func singleRoot() throws -> [Channel]? {
        let rows = m3u.components(separatedBy:"\n");
        var chanel = Channel()
        for row in rows {
            
            if row.hasPrefix("#EXTM3U") {
                continue
            }
            else if row.hasPrefix("#EXT") {
                chanel.prop = try self.parseProperties(row: row)
                chanel.name = row.components(separatedBy: ",").last?.trimmingCharacters(in: .whitespaces)
            }
            else if row.contains("://") {
                chanel.url = row.trimmingCharacters(in: .whitespaces)
                listach.append(chanel)
                chanel = Channel()
            }
        }
        return listach
    }
    
    func parseProperties(row: String) throws -> [String: String] {
        var retdict = [String: String]()
//        let regex = "#EXT.*:-?[0-9]+\\s(.*?=.*?)\\s?\\,\\s?(.*?$)"
        let regex = "#EXT.*:(-?\\d+)\\s(.*?=.*?)\\s?\\,\\s?(.*?$)"
        let RE = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
        let matches = RE.matches(in: row, options: .reportProgress, range: NSRange(location: 0, length: row.count))
        print(matches.count)
        for item in matches {
            let string = (row as NSString).substring(with: item.range)
            print(string)
        }
        
        let xs = row.replacingOccurrences(of: ",", with: " ").replacingOccurrences(of: "\"", with: "").components(separatedBy: " ")
        for str in xs {
            if str.contains("=") {
                let ixs = str.components(separatedBy: "=")
                if ixs.count == 2 {
                    retdict[ixs.first ?? ""] = ixs.last
                }
            }
        }
        return retdict
    }
}
