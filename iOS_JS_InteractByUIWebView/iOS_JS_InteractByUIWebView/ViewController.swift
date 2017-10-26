//
//  ViewController.swift
//  iOS_JS_InteractByUIWebView
//
//  Created by Mazy on 2017/10/26.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        webView = UIWebView(frame: UIScreen.main.bounds)
        webView.delegate = self
        
        let htmlURL = Bundle.main.url(forResource: "Index.html", withExtension: nil)
        let request = URLRequest(url: htmlURL!)
    
        // 如果不想要webView 的回弹效果
        webView.scrollView.bounces = false
        // UIWebView 滚动的比较慢，这里设置为正常速度
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        
        // 请求数据
        webView.loadRequest(request)
    
        view.addSubview(webView)
        
    }
}

extension ViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("webViewDidStartLoad")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("webViewDidFinishLoad")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("didFailLoadWithError \(error)")
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url, let scheme = url.scheme else {
            return false
        }
        if scheme == "iOSAction" {
            self.handleCustomAction(url: url)
            return false
        }
        return true
    }
}

extension ViewController {
    
    func handleCustomAction(url: URL) {
        guard let host = url.host else {
            return
        }
        print(host)
    }
}

