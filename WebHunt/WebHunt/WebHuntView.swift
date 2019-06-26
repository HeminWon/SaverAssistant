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
    
    static var previewView: WebHuntView?
    
    static var sharingWebs: Bool {
        let preferences = Preferences.sharedInstance
        return (preferences.multiMonitorMode == Preferences.MultiMonitorMode.mirrored.rawValue)
    }
    
    static var instanciatedViews: [WebHuntView] = []
    
    static var singlePlayerAlreadySetup: Bool = false
    static var sharedPlayerIndex: Int?
    
    class var sharedWebView: WKWebView {
        struct Static {
            static let instance: WKWebView = WKWebView()
            static var _webView: WKWebView?
            static var webView: WKWebView {
                if let activeWebView = _webView {
                    return activeWebView
                }
                _webView = WKWebView()
                return _webView!
            }
        }
        return Static.webView
    }
    
    // MARK: init
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function) \(frame) \(isPreview)")
        setup()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function) \(decoder)")
        setup()
    }
    
    deinit {
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
    }
    
    // MARK: Lifecycle stuff
    override func startAnimation() {
        super.startAnimation()
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
    }
    
    override func stopAnimation() {
        super.stopAnimation()
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
    }
    
    // MARK: Private
    func setup(){
        
        var localWebView : WKWebView?
        let notPreview = !isPreview
        
        if notPreview {
            //
        } else {
            WebHuntView.previewView = self
        }
        
        if localWebView == nil {
            if WebHuntView.sharingWebs {
                localWebView = WebHuntView.sharedWebView
            } else {
                localWebView = WKWebView()
            }
        }
        
        guard let webView = localWebView else {
            return
        }
        
        setupWebView(withWebView: webView)
        
        // We're NOT sharing the preview !!!!!
        if !isPreview {
            WebHuntView.singlePlayerAlreadySetup = true
            WebHuntView.sharedPlayerIndex = WebHuntView.instanciatedViews.count - 1
        }
        
        ManifestLoader.instance.addCallback { _ in
            debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
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
    
    // MARK: delegate WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.wkWebView?.isHidden = false
    }
    
    override var hasConfigureSheet: Bool {
        return true
    }
    
    override var configureSheet: NSWindow? {
        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
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
//        debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
    }
    
    // MARK:
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
