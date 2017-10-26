//
//  ViewController.swift
//  iOS_JS_InteractByMessageHandler
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
        preferences.minimumFontSize = 38
        configuration.preferences = preferences
        
        self.webView = WKWebView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300), configuration: configuration)
        
        let url = Bundle.main.url(forResource: "index.html", withExtension: nil)!
        self.webView.loadFileURL(url, allowingReadAccessTo: url)
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // addScriptMessageHandler 很容易导致循环引用
        // 控制器 强引用了WKWebView,WKWebView copy(强引用了）configuration， configuration copy （强引用了）userContentController
        // userContentController 强引用了 self （控制器）
        self.webView.configuration.userContentController.add(self, name: "ScanAction")
        self.webView.configuration.userContentController.add(self, name: "Location")
        self.webView.configuration.userContentController.add(self, name: "Share")
        self.webView.configuration.userContentController.add(self, name: "Color")
        self.webView.configuration.userContentController.add(self, name: "Pay")
        self.webView.configuration.userContentController.add(self, name: "Shake")
        self.webView.configuration.userContentController.add(self, name: "GoBack")
        self.webView.configuration.userContentController.add(self, name: "PlaySound")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "ScanAction")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "Location")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "Share")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "Color")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "Pay")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "GoBack")
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "PlaySound")
        
    }
}

extension ViewController: WKUIDelegate, WKNavigationDelegate,WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
        print(message.body)
        handleCustomAction(message: message)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertVC = UIAlertController(title: "温馨提示", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: { (_) in
            completionHandler()
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension ViewController {
    
    func handleCustomAction(message: WKScriptMessage) {
        let host = message.name
        if host == "ScanAction" {
            print("扫一扫")
        } else if host == "Location" {
            getLocation()
        } else if host == "Share" {
            let body = message.body as! [String : Any]
            shareAction(dict: body)
        } else if host == "Color" {
            let body = message.body as! [CGFloat]
            changeBGColor(body: body)
        } else if host == "Pay" {
            let body = message.body as! [String : Any]
            payAction(dict: body)
        } else if host == "PlaySound" {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        } else if host == "GoBack" {
            webView.goBack()
        }
        
    }
    
    
    /// 分享
    fileprivate func shareAction(dict: [String : Any]) {
        
        let title = dict["title"] ?? ""
        let content = dict["content"] ?? ""
        let url = dict["url"] ?? ""
        
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
    fileprivate func changeBGColor(body: [CGFloat]) {
        print(body)
        self.view.backgroundColor = UIColor(red: body[0]/255.0, green: body[1]/255.0, blue: body[2]/255.0, alpha: body[3])
    }
    
    fileprivate func payAction(dict: [String : Any]) {
        // 通过 URL 获取支付参数，进行支付操作
        
        let amount = dict["amount"] as! Int
        let name = dict["channel"] as! String
        let order_no = dict["order_no"] as! String
        let subject = dict["subject"] as! String
        
        let jsStr = "payResult('\("支付成功")','\(amount)','\(name)','\(order_no)', '\(subject)')"
        self.webView.evaluateJavaScript(jsStr) { (result, error) in
            print("result = \(result.debugDescription), error = \(String(describing: error?.localizedDescription))")
        }
    }
}
