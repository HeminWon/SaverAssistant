//
//  main.swift
//  IssueTrain
//
//  Created by HeminWon on 2018/7/22.
//  Copyright © 2018 HeminWon. All rights reserved.
//

import AppKit

autoreleasepool { () -> () in
    let app = NSApplication.shared // 创建应用
    let delegate = AppDelegate()
    app.delegate = delegate // 配置应用代理
    app.run() // 启动应用
}
