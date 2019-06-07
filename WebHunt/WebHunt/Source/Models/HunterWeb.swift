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

final class HunterWeb {
    let url: String
    
    init(url: String) {
        self.url = url
    }
}
