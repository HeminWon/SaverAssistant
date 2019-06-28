//
//  HunterWeb.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/7.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Foundation

enum Manifests: String {
    case Original = "hunt-original.json"
}

class HunterWeb {
    let url: String
    let description: String
    let type: String
    
    init(url: String, description: String, type: String) {
        self.url = url
        self.description = description
        self.type = type
    }
}
