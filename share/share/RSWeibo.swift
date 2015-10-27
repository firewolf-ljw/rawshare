//
//  Weibo.swift
//  share
//
//  Created by  lifirewolf on 15/8/1.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import UIKit

class RSWeibo: RawShare {
    
    static let domain: String = "Weibo"
    
    static func register(appKey: String) {
        let wb = RSWeibo(appKey: appKey)
        ShareManager.cacheShare(RSWeibo.domain, schemes: ["wb\(wb.appKey)"], share: wb)
    }
    
    var appKey: String
    
    private init(appKey: String) {
        self.appKey = appKey
        super.init(domain: RSWeibo.domain)
    }
    
    func isWeiboInstalled() -> Bool {
        return self.canOpen("weibosdk://request")
    }
        
    func shareToWeibo(msg: Message, success: shareSuccess, fail: shareFail) {

        self.prepareShare(msg, success: success, fail: fail)
        
        var message = Dictionary<String, AnyObject>()
        
        if msg.checkProperty(["link", "image"], notNilPropertys: ["title"]) {
            //text类型分享
            message["__class"] = "WBMessageObject"
            message["text"] = msg.title!
        } else if msg.checkProperty(["link"], notNilPropertys: ["title", "image"]) {
            //图片类型分享
            message["__class"] = "WBMessageObject"
            message["imageObject"] = ["imageData" : msg.image!]
            message["text"] = msg.title!
        } else if msg.checkProperty(nil, notNilPropertys: ["title", "image", "link"]) {
            //链接类型分享
            message["__class"] = "WBMessageObject"
            message["mediaObject"] =
                ["__class": "WBWebpageObject",
                "description": msg.desc != nil ? msg.desc! : msg.title!,
                "objectID": "identifier1",
                "thumbnailData": msg.thumbnail != nil ? msg.thumbnail! : msg.image!,
                "title": msg.title!,
                "webpageUrl": msg.link!]
        }
        
        let uuid = Utils.createUUID()
    
        let messageData: [AnyObject] = [
            ["transferObject": NSKeyedArchiver.archivedDataWithRootObject(["__class" : "WBSendMessageToWeiboRequest", "message":message, "requestID" :uuid])
            ],
            ["userInfo": NSKeyedArchiver.archivedDataWithRootObject([])],
    
            ["app": NSKeyedArchiver.archivedDataWithRootObject(["appKey" : self.appKey, "bundleID" : self.CFBundleIdentifier()])]
        ]
        
        UIPasteboard.generalPasteboard().items = messageData
        self.openURL("weibosdk://request?id=\(uuid)&sdkversion=003013000")
        
    }
    
    func weiboAuth(redirectURI: String, success: authSuccess, fail: authFail) {
        
        let scope = "all"
        
        self.prepareAuth(success, fail: fail)
        
        let uuid = Utils.createUUID()

        let authData: [AnyObject] = [
            ["transferObject": NSKeyedArchiver.archivedDataWithRootObject(["__class" : "WBAuthorizeRequest", "redirectURI":redirectURI, "requestID" :uuid, "scope": scope])
            ],
            ["userInfo": NSKeyedArchiver.archivedDataWithRootObject(["mykey": "as you like", "SSO_From": "SendMessageToWeiboViewController"])],
            
            ["app": NSKeyedArchiver.archivedDataWithRootObject(["appKey" : self.appKey, "bundleID" : self.CFBundleIdentifier(), "name": self.CFBundleDisplayName()])]
        ]
    
        UIPasteboard.generalPasteboard().items = authData
        self.openURL("weibosdk://request?id=\(uuid)&sdkversion=003013000")
    }
    
    override func handleOpenURL(callbackUrl: NSURL) -> Bool {
        
        var flag = false
        
        let url = callbackUrl
        
        if url.scheme.hasPrefix("wb") {
            
            let items = UIPasteboard.generalPasteboard().items
            
            let ret: NSMutableDictionary = NSMutableDictionary(capacity: items.count)
            
            for item in items as! [Dictionary<String, AnyObject>] {
                for (key, value) in item {
                    ret[key] = key == "sdkVersion" ? value : NSKeyedUnarchiver.unarchiveObjectWithData(value as! NSData)
                }
            }
            
            if let transferObject: Dictionary<String, AnyObject> = ret["transferObject"] as? Dictionary<String, AnyObject> {
                if transferObject["__class"] as? String == "WBAuthorizeResponse" {
                    // auth
                    let code = transferObject["statusCode"] as? Int
                    if code != nil && code == 0 {
                        if let callback = self.authSuccessCallback {
                            callback(message: transferObject)
                        }
                    } else {
                        if let callback = self.authFailCallback {
                            let error = NSError(domain: "weibo_auth_response", code: code != nil ? code! : -1, userInfo:nil)
                            callback(message: transferObject, error: error)
                        }
                    }
                    
                } else if transferObject["__class"] as? String == "WBSendMessageToWeiboResponse" {
                    // share
                    let code = transferObject["statusCode"] as? Int
                    if code != nil && code == 0 {
                        if let callBack = self.shareSuccessCallback {
                            callBack(message: transferObject)
                        }
                    } else {
                        if let callBack = self.shareFailCallback {
                            let error = NSError(domain: "weibo_share_response", code: code != nil ? code! : -1, userInfo:nil)
                            callBack(message: transferObject, error: error)
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
