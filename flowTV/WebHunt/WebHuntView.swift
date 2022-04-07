//
//  WebHuntView.swift
//  WebHunt
//
//  Created by Hemin Won on 2019/6/2.
//  Copyright © 2019 HeminWon. All rights reserved.
//

import ScreenSaver
import WebKit
import RxSwift
import AVKit
import AVFoundation

class WebHuntView: ScreenSaverView {
    
    var preferencesWindowController: PreferencesWindowController?
    
    static var previewView: WebHuntView?
    static var sharedViews: [WebHuntView] = []
    
    let disposeBag = DisposeBag()
    
    static var sharingWebs: Bool {
        let preferences = Preferences.sharedInstance
        return (preferences.newViewingMode == Preferences.NewViewingMode.mirrored.rawValue) ||
            (preferences.newViewingMode == Preferences.NewViewingMode.spanned.rawValue)
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

        let displayDetection = DisplayDetection.sharedInstance
        infoLog("\(displayDetection.screens)")
        
        WebHuntView.sharedViews.append(self)
        
        setupWebView()
        
        ManifestLoader.instance.addCallback { channels in
            debugLog("\(self.description) \(fileName(#file)):\(#line) \(#function)")
            
            for (n, vie) in WebHuntView.sharedViews.enumerated() {
                
                
                guard let urlStr = channels[n].url else {
                    return
                }
                let url = NSURL(string: urlStr)
                debugLog("url:\(urlStr) view:\(vie)")
                let playerItem = AVPlayerItem(url: url! as URL)
                vie.avview.player?.replaceCurrentItem(with: playerItem)
            }
        }
    }
    
    let avview = AVPlayerView()
    let avplayer = AVPlayer()
    let playVC = AVPlayerLayer()

    func setupWebView() {
        let url = NSURL(string: "http://iptv.tvfix.org/hls/cctv13hd.m3u8")
        let playerItem = AVPlayerItem(url: url! as URL)
//        avPlayer.replaceCurrentItem(with: playerItem)
//        playVC.player = avplayer
//        playVC.player?.replaceCurrentItem(with: playerItem)
//        playVC.frame = self.bounds
//        playVC.player?.play()
//        self.layer?.addSublayer(playVC)
        avview.player = avplayer
//        avview.player?.isMuted = true
        avview.player?.volume = 0.0
        avview.player?.replaceCurrentItem(with: playerItem)
        avview.controlsStyle = .none
        avview.frame = self.bounds
        avview.player?.play()
        avview.window?.backgroundColor = NSColor.white
        self.addSubview(avview)
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
    }
    
    // MARK:
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

class WebHuntViewManager {
    static let manager:WebHuntViewManager = WebHuntViewManager()
    var ziping = false
    var subjects = [PublishSubject<WebHuntView>]()
}
