//
//  WeChat.swift
//  share
//
//  Created by  lifirewolf on 15/7/31.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import UIKit

class RSWeChat: RawShare {
    
    static let domain: String = "WeChat"
    
    static func register(appId: String) {
        let wc = RSWeChat(appId: appId)
        ShareManager.cacheShare(RSWeChat.domain, schemes: [wc.appId], share: wc)
    }
    
    var appId: String
    
    private init(appId: String) {
        self.appId = appId
        super.init(domain: RSWeChat.domain)
    }
    
    func isWeChatInstalled() -> Bool {
        return self.canOpen("weixin://")
    }
    
    func shareToWeChatSession(msg: Message, success: shareSuccess, fail: shareFail) {
        print("session")
        self.prepareShare(msg, success: success, fail: fail)
        
        let url = self.genWeChatShareUrl(msg, to:0)
        print(url)
        
        self.openURL(url)
    }
    
    func shareToWeChatTimeline(msg: Message, success:shareSuccess, fail:shareFail) {
        
        self.prepareShare(msg, success: success, fail: fail)
        self.openURL(self.genWeChatShareUrl(msg, to: 1))
    }
    
    func shareToWeChatFavorite(msg: Message, success: shareSuccess, fail: shareFail) {
        
        self.prepareShare(msg, success: success, fail: fail)
        self.openURL(self.genWeChatShareUrl(msg, to: 2))
    }
    
    func genWeChatShareUrl(msg: Message, to:Int) -> String {
        
        let dic: NSMutableDictionary = NSMutableDictionary(dictionary: ["result":"1","returnFromApp":"0","scene":"\(to)", "sdkver":"1.5","command":"1010"])
        
        if msg.messageType == nil {
            if msg.checkProperty(["image", "link"], notNilPropertys: ["title"]) {
                //文本
                dic["command"] = "1020"
                dic["title"] = msg.title
            } else if msg.checkProperty(["link"], notNilPropertys: ["image"]) {
                //图片
                dic["fileData"] = msg.image
                dic["thumbData"] = msg.thumbnail != nil ? msg.thumbnail : msg.image
                dic["objectType"] = "2"
            } else if msg.checkProperty(nil, notNilPropertys: ["link","title","image"]) {
                //有链接
                dic["description"] = msg.desc != nil ? msg.desc :msg.title;
                dic["mediaUrl"] = msg.link
                dic["objectType"] = "5"
                dic["thumbData"] = msg.thumbnail != nil ? msg.thumbnail :msg.image
                dic["title"] = msg.title
            }
        } else if msg.messageType == MSGType.Audio {
            //music
            dic["description"] = msg.desc != nil ? msg.desc : msg.title
            dic["mediaUrl"] = msg.link
            dic["mediaDataUrl"] = msg.mediaDataUrl
            dic["objectType"] = "3"
            dic["thumbData"] = msg.thumbnail != nil ? msg.thumbnail : msg.image
            dic["title"] = msg.title
        } else if msg.messageType == MSGType.Video {
            //video
            dic["description"] = msg.desc != nil ? msg.desc : msg.title
            dic["mediaUrl"] = msg.link
            dic["objectType"] = "4"
            dic["thumbData"] = msg.thumbnail != nil ? msg.thumbnail : msg.image
            dic["title"] = msg.title
        } else if msg.messageType == MSGType.App {
            //app
            dic["description"]=msg.desc != nil ? msg.desc : msg.title;
            if msg.extInfo != nil {
                dic["extInfo"] = msg.extInfo
            }
            dic["fileData"] = msg.image
            dic["mediaUrl"] = msg.link
            dic["objectType"] = "7"
            dic["thumbData"] = msg.thumbnail != nil ? msg.thumbnail : msg.image
            dic["title"] = msg.title
        } else if msg.messageType == MSGType.File {
            //file
            dic["description"] = msg.desc != nil ? msg.desc : msg.title
            dic["fileData"] = msg.image
            dic["objectType"] = "6"
            dic["fileExt"] = msg.fileExt != nil ? msg.fileExt : ""
            dic["thumbData"] = msg.thumbnail != nil ? msg.thumbnail : msg.image
            dic["title"] = msg.title
        }
        
        let obj:Dictionary = [self.appId: dic]
        do {
            let output = try NSPropertyListSerialization.dataWithPropertyList(obj, format: NSPropertyListFormat.BinaryFormat_v1_0, options: NSPropertyListWriteOptions())
        
            UIPasteboard.generalPasteboard().setData(output, forPasteboardType: "content")
        } catch {}
        return "weixin://app/\(self.appId)/sendreq/?"
        
    }
    
    /**
    *  注意：微信登录权限仅限已获得认证的开发者申请，请先进行开发者认证
    *
    *  @param success 登录成功回调
    *  @param fail    登录失败回调
    */
    func weChatAuth(success:authSuccess, fail:authFail) {
        //login scope: @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";//,post_timeline,sns
        let scope = "snsapi_userinfo"
        self.prepareAuth(success, fail: fail)
        self.openURL("weixin://app/\(self.appId)/auth/?scope=\(scope)&state=Weixinauth")
    }
    
    /**
    *  微信支付,不同于分享和登录，由于参数是服务器生成的，所以不需要connect。
    *
    *  @param link    服务器返回的link，以供直接打开
    *  @param success 微信支付成功的回调
    *  @param fail    微信支付失败的回调
    */
    func weChatPay(link: String, success:paySuccess, fail:payFail) {
        
        self.paySuccessCallback = success
        self.payFailCallback = fail
        openURL(link)
        
    }
    
    override func handleOpenURL(callbackUrl: NSURL) -> Bool {
        
        var flag = false
        
        let url = callbackUrl
            
        if url.scheme.hasPrefix("wx") {
            
            if let range = url.absoluteString.rangeOfString("://oauth") {
                if !range.isEmpty {
                    //login succcess
                    if self.authSuccessCallback != nil {
                        self.authSuccessCallback!(message: Utils.parseUrl(url))
                    }
                }
            } else if let range = url.absoluteString.rangeOfString("://pay/") {
                if !range.isEmpty {
                    let urlMap: Dictionary<String, String> = Utils.parseUrl(url)
                    let code: Int? = Int(urlMap["ret"]!)
                    
                    if code != nil && code! == 0 {
                        if self.paySuccessCallback != nil {
                            self.paySuccessCallback!(message: urlMap)
                        }
                    } else {
                        if self.payFailCallback != nil {
                            let error = NSError(domain: "weixin_pay", code: code!, userInfo:nil)
                            self.payFailCallback!(message: urlMap, error: error)
                        }
                    }
                }
            } else {
                
                let data = UIPasteboard.generalPasteboard().dataForPasteboardType("content")
                
                var retDic: NSDictionary?
                do {
                    retDic = try NSPropertyListSerialization.propertyListWithData(data!, options:NSPropertyListMutabilityOptions.MutableContainersAndLeaves, format: nil) as? NSDictionary
                } catch {}
                retDic = retDic?[self.appId] as? NSDictionary
                
                NSLog("retDic\n\(retDic)")
                
                if let dic = retDic {
                
                    var code: Int = -1
                    var zeroCode: Bool = false
                    
                    print(dic.objectForKey("result"))
                    
                    if let rstCode = dic["result"]?.integerValue {
                        code = rstCode
                        zeroCode = rstCode == 0 ? true : false
                    }
                    
                    var isWeixinAuth: Bool = false
                    if let state: AnyObject = dic["state"] {
                        if state.isEqualToString("Weixinauth") {
                            isWeixinAuth = true
                        }
                    }
                    
                    if zeroCode {
                        //分享成功
                        if let callBack = self.shareSuccessCallback {
                            callBack(message: dic)
                        }
                    } else if isWeixinAuth {
                        //登录失败
                        if let callBack = self.authFailCallback {
                            let error = NSError(domain: "weixin_auth", code: code, userInfo:nil)
                            callBack(message: dic, error: error)
                        }
                    } else {
                        //分享失败
                        if let callBack = self.shareFailCallback {
                            let error = NSError(domain: "weixin_share", code: code, userInfo:nil)
                            callBack(message: dic, error: error)
                        }
                    }
                }
            }
            flag = true
        }
        
        reset()
        
        return flag
    }
}