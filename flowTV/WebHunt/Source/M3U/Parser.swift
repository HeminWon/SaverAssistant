//
//  Parser.swift
//  WebHunt
//
//  Created by Hemin Won on 2022/4/5.
//  Copyright © 2022 HeminWon. All rights reserved.
//

import Foundation

public struct Channel {
    public fileprivate(set) var url: String?
    public fileprivate(set) var name: String?
    public fileprivate(set) var prop : [String: String]?
}

public struct M3U {
    public static func load(m3u: String) throws -> [Channel]? {
        return try Parser.init(m3u:m3u).singleRoot()
    }
}

public final class Parser {
    public let m3u: String
    
    var listach = [Channel]()
    
    public init(m3u string: String) throws {
        m3u = string
    }
    
    public func singleRoot() throws -> [Channel]? {
        let rows = m3u.components(separatedBy:"\n").filter { return $0.count > 0 }
        guard rows.count > 0 else {
            throw M3uError.invalidEXTM3U
        }
        guard rows.first!.hasPrefix("#EXTM3U") else {
            throw M3uError.invalidEXTM3U
        }
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
                guard chanel.name != nil else {
                    warnLog("channel name nil url:\(chanel.url!)")
                    continue
                }
                listach.append(chanel)
                chanel = Channel()
            }
        }
        return listach
    }
    
    func parseProperties(row: String) throws -> [String: String] {
        var retdict = [String: String]()
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
