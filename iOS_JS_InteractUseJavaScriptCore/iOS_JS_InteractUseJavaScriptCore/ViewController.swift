//
//  ViewController.swift
//  iOS_JS_InteractUseJavaScriptCore
//
//  Created by Mazy on 2017/10/27.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    fileprivate var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration:WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        
        let preferences: WKPreferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.minimumFontSize = 30
        configuration.preferences = preferences
        
        self.webView = WKWebView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300), configuration: configuration)
        
        let url = Bundle.main.url(forResource: "index.html", withExtension: nil)!
        self.webView.loadFileURL(url, allowingReadAccessTo: url)
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
    }
}


extension ViewController: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertVC = UIAlertController(title: "温馨提示", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: { (_) in
            completionHandler()
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let scheme = url.scheme else {
            decisionHandler(.allow)
            return
        }
        if scheme == "iosaction" {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
        
    }
}
