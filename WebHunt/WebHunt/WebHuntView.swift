//
//  WebHuntView.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/2.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import ScreenSaver
import WebKit

class WebHuntView: ScreenSaverView, WKNavigationDelegate {

    var wkWebView: WKWebView?
    
    var preferencesWindowController: PreferencesWindowController?
    
    var currentWeb: HunterWeb?
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }
    
    func setup(){
        setupWebView(withWebView: nil)
        
        ManifestLoader.instance.addCallback { _ in
            self.updateURL()
        }
    }
    
    func setupWebView(withWebView webView: WKWebView?) {
        if self.wkWebView != nil {
            return;
        }
        let webViewConfiguration = WKWebViewConfiguration.init()
        let wkWebView = WKWebView.init(frame: self.bounds, configuration: webViewConfiguration)
        wkWebView.isHidden = true
        wkWebView.navigationDelegate = self
        self.wkWebView = wkWebView
        self.addSubview(wkWebView)
    }
    
    override func startAnimation() {
        super.startAnimation()
        
        updateURL()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    func updateURL() {
        if let wkWebView = self.wkWebView {
            wkWebView.stopLoading()
            
//            let urlString = "http://fakeupdate.net/win8/"
//            let urlString = "http://globe.cid.harvard.edu/?mode=gridSphere&id=CN"
//            let urlString = "http://stuffin.space/?intldes=2010-064A&search=china"
            
            let randomWeb = ManifestLoader.instance.randomWeb(excluding: [])
            
            guard let web = randomWeb else {
                return
            }
            
            self.currentWeb = web
            
            let url = URL(string: web.url)!
            
            let requ = URLRequest.init(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
            if (url.scheme == "http" || url.scheme == "https") {
                wkWebView.load(requ)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.wkWebView?.isHidden = false
    }
    
    override var hasConfigureSheet: Bool {
        return true
    }
    
    override var configureSheet: NSWindow? {
        if let controller = preferencesWindowController {
            return controller.window
        }
        
        let storyboard = NSStoryboard(name: "Preferences", bundle: Bundle.init(for: WebHuntView.self))
        let controller = storyboard.instantiateInitialController() as! NSWindowController
        preferencesWindowController = controller as? PreferencesWindowController
        return controller.window
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
