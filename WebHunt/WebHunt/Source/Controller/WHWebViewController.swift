//
//  WHWebViewController.swift
//  WebHunt
//
//  Created by 王明海 on 2019/7/14.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import Cocoa
import WebKit

class WHWebViewController: NSViewController,WKNavigationDelegate {

    lazy var webVIew: WKWebView = {
        let webViewConfiguration = WKWebViewConfiguration.init()
        let webView = WKWebView(frame:CGRect.zero, configuration: webViewConfiguration)
        return webView
    }()
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        webVIew.navigationDelegate = self
        webVIew.isHidden = true
        self.view = webVIew
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    // MARK: delegate WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.isHidden = false
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function) \(webView) \(webView.frame) \(webView.isHidden)")
    }
}
