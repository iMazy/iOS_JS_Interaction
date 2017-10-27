//
//  ViewController.swift
//  iOS_JS_InteractUseJavaScriptCore
//
//  Created by Mazy on 2017/10/27.
//  Copyright © 2017年 Mazy. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore
import AVFoundation

class ViewController: UIViewController {
    
    fileprivate var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
        webView.delegate = self
        
        let htmlURL = Bundle.main.url(forResource: "index.html", withExtension: nil)
        let request = URLRequest(url: htmlURL!)
    
        // 如果不想要webView 的回弹效果
//        webView.scrollView.bounces = false
        // UIWebView 滚动的比较慢，这里设置为正常速度
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        
        // 请求数据
        webView.loadRequest(request)
        
        view.addSubview(webView)
    }
}

extension ViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        addCustomActions()
    }
}

extension ViewController {
    
    fileprivate func addCustomActions() {
        guard let context = self.webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext else { return }
        addShareWithContext(context)
        addScanWithContext(context)
        addLocationWithContext(context)
        addSetBGColorWithContext(context)
        addPayActionWithContext(context)
        addShakeActionWithContext(context)
        addGoBackWithContext(context)
    }
    
    func addScanWithContext(_ context: JSContext) {
        
        let callBack : @convention(block) (AnyObject?) -> Void = {_ in
            print("扫一扫")
        }
        
        context.setObject(unsafeBitCast(callBack, to: AnyObject.self), forKeyedSubscript: "scan" as NSCopying & NSObjectProtocol)
        
    }
    
    func addLocationWithContext(_ context: JSContext) {
        let callBack : @convention(block) (AnyObject?) -> Void = { _ in
            //    Waiting
            let jsStr = "setLocation('\("湖北省—武汉市")')"
            JSContext.current().evaluateScript(jsStr)
        }
        
        context.setObject(unsafeBitCast(callBack, to: AnyObject.self), forKeyedSubscript: "getLocation" as NSCopying & NSObjectProtocol)
    }
    
    func addSetBGColorWithContext(_ context: JSContext) {
        let callBack : @convention(block) (AnyObject?) -> Void = { [weak self] (paramFromJS) -> Void in
            //    Waiting
            let value = JSContext.currentArguments() as! [JSValue]
            let r = value[0].toDouble()
            let g = value[1].toDouble()
            let b = value[2].toDouble()
            let a = value[3].toDouble()
            DispatchQueue.main.sync {
                self?.view.backgroundColor = UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: CGFloat(a))
            }
        }
        
        context.setObject(unsafeBitCast(callBack, to: AnyObject.self), forKeyedSubscript: "setColor" as NSCopying & NSObjectProtocol)
        
    }
    
    func addShareWithContext(_ context: JSContext) {
        
        let callBack : @convention(block) (AnyObject?) -> Void = {_ in
            //    Waiting
            let value = JSContext.currentArguments() as! [JSValue]
            let title = value[0].toString() ?? ""
            let content = value[1].toString() ?? ""
            let url = value[2].toString() ?? ""
            let jsStr = "shareResult('\(title)','\(content)', '\(url)')"
            JSContext.current().evaluateScript(jsStr)
        }
        
        context.setObject(unsafeBitCast(callBack, to: AnyObject.self), forKeyedSubscript: "share" as NSCopying & NSObjectProtocol)
    }
    
    func addPayActionWithContext(_ context: JSContext) {
        let callBack : @convention(block) (AnyObject?) -> Void = { _ in
            
            let value = JSContext.currentArguments() as! [JSValue]
            let orderNo = value[0].toString() ?? ""
            let channel = value[1].toString() ?? ""
            let amount = value[2].toString() ?? ""
            let subject = value[3].toString() ?? ""
            let jsStr = "payResult('\(orderNo)','\(channel)', '\(amount)', '\(subject)')"
            JSContext.current().evaluateScript(jsStr)
        }
        
        context.setObject(unsafeBitCast(callBack, to: AnyObject.self), forKeyedSubscript: "payAction" as NSCopying & NSObjectProtocol)
    }
    
    func addShakeActionWithContext(_ context: JSContext) {
        let callBack : @convention(block) (AnyObject?) -> Void = { _ in
            AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        }
        
        context.setObject(unsafeBitCast(callBack, to: AnyObject.self), forKeyedSubscript: "shake" as NSCopying & NSObjectProtocol)
    }
    
    func addGoBackWithContext(_ context: JSContext) {
        let callBack : @convention(block) (AnyObject?) -> Void = { [weak self] (paramFromJS) -> Void in
            self?.webView.goBack()
        }
        
        context.setObject(unsafeBitCast(callBack, to: AnyObject.self), forKeyedSubscript: "goBack" as NSCopying & NSObjectProtocol)
    }
}
