//
//  QQ.swift
//  share
//
//  Created by  lifirewolf on 15/7/31.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import UIKit

class RSQQ: RawShare {
    
    static let domain: String = "QQ"
    
    static func register(appId: String) {
        let qq = RSQQ(appId: appId)
        
        ShareManager.cacheShare(RSQQ.domain, schemes: [qq.callbackName, "tencent\(appId)", "tencent\(appId).content"], share: qq)
    }
    
    enum Type: Int {
        case kQQAPICtrlFlagQZoneShareOnStart = 1
        case kQQAPICtrlFlagQZoneShareForbid = 2
        case kQQAPICtrlFlagQQShare = 4
        case kQQAPICtrlFlagQQShareFavorites = 8 //收藏
        case kQQAPICtrlFlagQQShareDataline = 16  //数据线
    }
    
    var appId: String
    var callbackName: String
    
    private init(appId: String) {
        self.appId = appId
        var cb = NSString(format: "QQ%02llx", NSString(string: appId).longLongValue)
        self.callbackName = cb.uppercaseString
        
        super.init(domain: RSQQ.domain)
    }
    
    func isQQInstalled() -> Bool {
        return self.canOpen("mqqapi://")
    }
    
    func shareToQQFriends(msg: Message, success:shareSuccess, fail:shareFail) {
        self.prepareShare(msg, success:success, fail:fail)
        self.openURL(self.genShareUrl(msg, to:0))
    }
    
    func shareToQQZone(msg: Message, success:shareSuccess, fail:shareFail) {
        self.prepareShare(msg, success:success, fail:fail)
        self.openURL(self.genShareUrl(msg, to:Type.kQQAPICtrlFlagQZoneShareOnStart.rawValue))
    }
    
    func shareToQQFavorites(msg: Message, success:shareSuccess, fail:shareFail) {
        self.prepareShare(msg, success:success, fail:fail)
        self.openURL(self.genShareUrl(msg, to:Type.kQQAPICtrlFlagQQShareFavorites.rawValue))
    }
    
    func shareToQQDataline(msg: Message, success:shareSuccess, fail:shareFail) {
        self.prepareShare(msg, success:success, fail:fail)
        self.openURL(self.genShareUrl(msg, to:Type.kQQAPICtrlFlagQQShareDataline.rawValue))
    }
    
    func qqAuth(scope: String, success:authSuccess, fail:authFail) {
        self.prepareAuth(success, fail:fail)

        var authData: Dictionary<String, AnyObject> =
            ["app_id":self.appId,
            "app_name":self.CFBundleDisplayName(),
            "client_id":self.appId,
            "response_type":"token",
            "scope":scope,
            "sdkp":"i",
            "sdkv":"2.9",
            "status_machine":UIDevice.currentDevice().model,
            "status_os":UIDevice.currentDevice().systemVersion,
            "status_version":UIDevice.currentDevice().systemVersion]
    
        Utils.setGeneralPasteboard("com.tencent.tencent\(self.appId)", value:authData, encoding: .KeyedArchiver)
        
        self.openURL("mqqOpensdkSSoLogin://SSoLogin/tencent\(self.appId)/com.tencent.tencent\(self.appId)?generalpastboard=1")
    }
    
    func genShareUrl(msg: Message, to:Int) -> String {
        
        var ret = NSMutableString(string: "mqqapi://share/to_fri?thirdAppDisplayName=")
        ret.appendString(self.CFBundleDisplayName())
        ret.appendString("&version=1&cflag=")
        ret.appendFormat("%d", to)
        ret.appendString("&callback_type=scheme&generalpastboard=1")
        ret.appendString("&callback_name=")
        ret.appendString(self.callbackName)
        ret.appendString("&src_type=app&shareType=0&file_type=")
        
        if msg.link != nil && msg.messageType == nil {
            msg.messageType = .News
        }
        
        if msg.checkProperty(["image", "link"], notNilPropertys: ["title"]) {
            //纯文本分享
            ret.appendString("text&file_data=")
            ret.appendString(Utils.base64AndUrlEncode(msg.title!))
        } else if msg.checkProperty(["link"], notNilPropertys: ["title", "image", "desc"]) {
            //图片分享
            let data: Dictionary<String, AnyObject> = ["file_data": msg.image!, "previewimagedata": (msg.thumbnail != nil ? msg.thumbnail! : msg.image!)]
            
            Utils.setGeneralPasteboard("com.tencent.mqq.api.apiLargeData", value: data, encoding: .KeyedArchiver)
            ret.appendString("img&title=")
            ret.appendString(Utils.base64Encode(msg.title!))
            ret.appendString("&objectlocation=pasteboard&description=")
            ret.appendString(Utils.base64Encode(msg.desc!))
        } else if msg.checkProperty(nil, notNilPropertys: ["title", "image", "desc", "link", "multimediaType"]) {
            //新闻／多媒体分享（图片加链接）发送新闻消息 预览图像数据，最大1M字节 URL地址,必填 最长512个字符
            var data: Dictionary<String, AnyObject> = ["previewimagedata": msg.image!]
            
            Utils.setGeneralPasteboard("com.tencent.mqq.api.apiLargeData", value: data, encoding: .KeyedArchiver)
            var msgType = "news"
            if (msg.messageType == .Audio) {
                msgType = "audio"
            }
            
            ret.appendFormat("%@&title=%@&url=%@&description=%@&objectlocation=pasteboard", msgType, Utils.base64AndUrlEncode(msg.title!), Utils.base64AndUrlEncode(msg.link!), Utils.base64AndUrlEncode(msg.desc!))
        }
        
        return "\(ret)"
    }

    override func handleOpenURL(callbackUrl: NSURL) -> Bool {
        
        var flag = false
        
        let url = callbackUrl
        
        if url.scheme!.hasPrefix("QQ") {
            //分享
            var urlMap: Dictionary<String, String> = Utils.parseUrl(url)
            if let err_desc = urlMap["error_description"] {
                urlMap["error_description"] = Utils.base64Decode(err_desc)
            }
            
            let err_code: Int? = urlMap["error"]?.toInt()
            
            if err_code != nil &&  err_code != 0 {
                if let callBack = self.shareFailCallback {
                    let error = NSError(domain: "response_from_qq", code: err_code!, userInfo:nil)
                    callBack(message: urlMap, error: error)
                }
            } else {
                if let callBack = self.shareSuccessCallback {
                    callBack(message: urlMap)
                }
            }
            
            flag = true
        } else if url.scheme!.hasPrefix("tencent") {
            //登陆auth
            let ret = Utils.generalPasteboardData("com.tencent.tencent\(appId)", encoding: .KeyedArchiver)
            
            let ret_code: Int? = ret?["ret"]?.integerValue
            
            if ret_code != nil && ret_code == 0 {
                if let callback = self.authSuccessCallback {
                    callback(message: ret!)
                }
            } else {
                if let callback = self.authFailCallback {
                    let error = NSError(domain: "auth_from_QQ", code: -1, userInfo:nil)
                    callback(message: ret!, error: error)
                }
            }
            
            flag = true
        }
        
        reset()
        
        return flag
    }
    
    func chatWithQQNumber(qqNumber: String) {
        let appName = Utils.base64Encode(self.CFBundleDisplayName())
        let url = "mqqwpa://im/chat?uin=\(qqNumber)&thirdAppDisplayName=\(appName)&callback_name=\(self.callbackName)&src_type=app&version=1&chat_type=wpa&callback_type=scheme"
        self.openURL(url)
    }
    
    func chatInQQGroup(groupNumber: String){
    
        let appName = Utils.base64Encode(self.CFBundleDisplayName())
        let url = "mqqwpa://im/chat?uin=\(groupNumber)&thirdAppDisplayName=\(appName)&callback_name=\(self.callbackName)&src_type=app&version=1&chat_type=group&callback_type=scheme"
        self.openURL(url)
    }
}