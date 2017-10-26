//
//  ViewController.swift
//  iOS_JS_InteractByUIWebView
//
//  Created by Mazy on 2017/10/26.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit
import AVFoundation

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
        /// 注意： 这个必须是小写
        if scheme == "iosaction" {
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
        self.webView.stringByEvaluatingJavaScript(from: jsStr)
    }
    
    // 获取位置
    fileprivate func getLocation() {
        let jsStr = "setLocation('北京市')"
        self.webView.stringByEvaluatingJavaScript(from: jsStr)
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
        
        if let rr = NumberFormatter().number(from: tempDict["r"]!),
           let gg = NumberFormatter().number(from: tempDict["g"]!),
           let bb = NumberFormatter().number(from: tempDict["b"]!),
           let aa = NumberFormatter().number(from: tempDict["a"]!)
            {
                let r = CGFloat(truncating: rr)
                let g = CGFloat(truncating: gg)
                let b = CGFloat(truncating: bb)
                let a = CGFloat(truncating: aa)
                self.webView.backgroundColor = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
        }
    }
    
    fileprivate func payAction(url: URL) {
        // 通过 URL 获取支付参数，进行支付操作
        let jsStr = "payResult('\("支付成功")','True')"
        self.webView.stringByEvaluatingJavaScript(from: jsStr)
    }
}

