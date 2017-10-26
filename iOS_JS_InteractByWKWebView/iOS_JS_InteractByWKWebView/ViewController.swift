//
//  ViewController.swift
//  iOS_JS_InteractByWKWebView
//
//  Created by Mazy on 2017/10/26.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish navigation")
    }
    
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
            self.handleCustomAction(url: url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)

    }
}

extension ViewController {
    
    func handleCustomAction(url: URL) {
        guard let host = url.host else {
            return
        }
        print(host)
        if host == "scanClick" {
            print("扫一扫")
        } else if host == "shareClick" {
            shareAction(url: url)
        } else if host == "getLocation" {
            getLocation()
        } else if host == "setColor" {
            changeBGColor(url: url)
        } else if host == "payAction" {
            payAction(url: url)
        } else if host == "shake" {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        } else if host == "goBack" {
            webView.goBack()
        }
        
    }
    
    
    /// 分享
    fileprivate func shareAction(url: URL) {
        guard let params = url.query?.components(separatedBy: "&") else {
            return
        }
        var tempDict = [String: String]()
        for param in params {
            let dicArray = param.components(separatedBy: "=")
            if dicArray.count > 1 {
                // 字符编码 removingPercentEncoding
                let decodeValue = dicArray[1].removingPercentEncoding
                tempDict[dicArray[0]] = decodeValue
            }
        }
        let title = tempDict["title"] ?? ""
        let content = tempDict["content"] ?? ""
        let url = tempDict["url"] ?? ""
        
        // 将分享结果返回给js
        let jsStr = "shareResult('\(title)','\(content)','\(url)')"
        self.webView.evaluateJavaScript(jsStr) { (result, error) in
            print("result = \(result.debugDescription), error = \(String(describing: error?.localizedDescription))")
        }
    }
    
    // 获取位置""
    fileprivate func getLocation() {
        let jsStr = "setLocation('北京市')"
        self.webView.evaluateJavaScript(jsStr) { (result, error) in
            print("result = \(result.debugDescription), error = \(String(describing: error?.localizedDescription))")
        }
    }
    
    /// 改变颜色
    fileprivate func changeBGColor(url: URL) {
        guard let params = url.query?.components(separatedBy: "&") else {
            return
        }
        var tempDict = [String: String]()
        for param in params {
            let dicArray = param.components(separatedBy: "=")
            if dicArray.count > 1 {
                // 字符编码 removingPercentEncoding
                let decodeValue = dicArray[1].removingPercentEncoding
                tempDict[dicArray[0]] = decodeValue
            }
        }
        
        if  let rr = NumberFormatter().number(from: tempDict["r"]!),
            let gg = NumberFormatter().number(from: tempDict["g"]!),
            let bb = NumberFormatter().number(from: tempDict["b"]!),
            let aa = NumberFormatter().number(from: tempDict["a"]!)
        {
            let r = CGFloat(truncating: rr)
            let g = CGFloat(truncating: gg)
            let b = CGFloat(truncating: bb)
            let a = CGFloat(truncating: aa)
            self.webView.backgroundColor = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
            self.view.backgroundColor = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
        }
    }
    
    fileprivate func payAction(url: URL) {
        // 通过 URL 获取支付参数，进行支付操作
        let jsStr = "payResult('\("支付成功")','True')"
        self.webView.evaluateJavaScript(jsStr) { (result, error) in
            print("result = \(result.debugDescription), error = \(String(describing: error?.localizedDescription))")
        }
    }
}

