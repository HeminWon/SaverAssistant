//
//  WebHuntView.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/2.
//  Copyright © 2019 Burns5. All rights reserved.
//

import ScreenSaver
import WebKit

class WebHuntView: ScreenSaverView, WKNavigationDelegate {

    var wkWebView: WKWebView?
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func startAnimation() {
        super.startAnimation()
        let webViewConfiguration = WKWebViewConfiguration.init()
        let wkWebView = WKWebView.init(frame: self.bounds, configuration: webViewConfiguration)
        wkWebView.navigationDelegate = self
        self.wkWebView = wkWebView
        updateURL()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    func updateURL() {
        if let wkWebView = self.wkWebView {
            wkWebView.stopLoading()
            
            let urlString = "http://fakeupdate.net/win8/"
            
            let url = URL(string: urlString)!
            if (url.scheme == "http" || url.scheme == "https") {
                wkWebView.load(URLRequest(url: url))
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.addSubview(webView)
    }
    
    override var hasConfigureSheet: Bool {
        return false
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
