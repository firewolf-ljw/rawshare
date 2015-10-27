//
//  AliPay.swift
//  share
//
//  Created by  lifirewolf on 15/8/2.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import UIKit

class RSAliPay: RawShare {
    
    static let domain: String = "AliPay"
    
    static func register(callBackName: String) {
        let ap = RSAliPay(callBackName: callBackName)
        ShareManager.cacheShare(RSAliPay.domain, schemes: [ap.callBackName], share: ap)
    }
    
    var callBackName: String
    
    private init(callBackName: String) {
        self.callBackName = callBackName
        super.init(domain: RSAliPay.domain)
    }
    
    func isAlipayInstalled() -> Bool {
        return self.canOpen("alipay://")
    }
    
    func aliPay(link: String, success: paySuccess, fail: payFail) {
        self.reset()
        self.paySuccessCallback = success
        self.payFailCallback = fail
        
        if self.isAlipayInstalled() {
            //支付宝为了用户体验，会把截屏放在支付的后面当背景，可选项。当然也可以用其他的自己生成的UIImage，比如[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default@2x" ofType:@"png"]]
            let screenShot: UIImage = Utils.screenshot()
            //获取到fromAppUrlScheme，来设置截屏。
            
            if let range = link.rangeOfString("?") {
                var linkStr = link[range.endIndex ..< link.endIndex]
                
                linkStr = Utils.urlDecode(linkStr)
                
                var linkDic: [String: AnyObject]
                do {
                    linkDic = try NSJSONSerialization.JSONObjectWithData(linkStr.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                } catch {
                    linkDic = [String: AnyObject]()
                }
                
                let obj = ["image_data": UIImagePNGRepresentation(screenShot)!,
                    "scheme" : linkDic["fromAppUrlScheme"]!
                ]
                let d = NSKeyedArchiver.archivedDataWithRootObject(obj)
                UIPasteboard.generalPasteboard().setData(d, forPasteboardType: "com.alipay.alipayClient.screenImage")
                
                self.openURL(link)
            }
        }
    }
    
    
    override func handleOpenURL(callbackUrl: NSURL) -> Bool {
        var flag = false
        
        let url = callbackUrl
        if let _ = url.absoluteString.rangeOfString("//safepay/") {
            
            var ret: NSDictionary
            do {
                ret = try NSJSONSerialization.JSONObjectWithData(Utils.urlDecode(url.query!).dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)  as! NSDictionary
            
                var isSuccess = false
                if let memo = ret["memo"] as? NSDictionary {
                    if let code = memo["ResultStatus"]?.integerValue {
                        if code == 9000 {
                            isSuccess = true
                        }
                    }
                }
                
                if isSuccess {
                    if let callBack = self.paySuccessCallback {
                        callBack(message: ret)
                    }
                } else {
                    if let callBack = self.payFailCallback {
                        let error = NSError(domain: "alipay_pay", code: -1, userInfo:nil)
                        callBack(message: ret, error: error)
                    }
                }

                flag = true
            } catch {}
        }
        
        reset()
        
        return flag
    }
    
    
}