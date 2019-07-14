//
//  HunterWeb.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/7.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Foundation

class Subscriber {
    let url: URL
    let remark: String
    
    init(url: URL, remark: String) {
        self.url = url
        self.remark = remark
    }
    
}

class HunterWeb {
    let url: String
    let remark: String?
    let group: String?
    var timeInterval: Int
    var timeExhibition: Int
    
    init(url: String, remark: String?, group: String?) {
        self.url = url
        self.remark = remark
        self.group = group
        self.timeInterval = 0
        self.timeExhibition = 0
    }
}
