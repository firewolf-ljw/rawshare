//
//  Share.swift
//  share
//
//  Created by  lifirewolf on 15/7/31.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import UIKit

/**
分享类型，除了news以外，还可能是video／audio／app等。
*/
enum MSGType {
    case News
    case Audio
    case Video
    case App
    case File
    case Undefined
}

/**
*  Message保存分享消息数据。
*/
class Message: NSObject {
    
    var title: String?
    var desc: String?
    var link: String?
    var image: NSData?
    var thumbnail: NSData?
    var messageType: MSGType?
    var extInfo: String?
    var mediaDataUrl: String?
    var fileExt: String?
    
    func checkProperty(nilPropertys: Array<String>?, notNilPropertys: Array<String>?) -> Bool {
        if nilPropertys != nil {
            for key in nilPropertys! {
                if self.valueForKeyPath(key) != nil {
                    return false
                }
            }
        }
        if notNilPropertys != nil {
            for key in notNilPropertys! {
                if self.valueForKeyPath(key) == nil {
                    return false
                }
            }
        }
        return true
    }
}

typealias shareSuccess = (message: NSDictionary) -> Void
typealias shareFail = (message: NSDictionary, error: NSError) -> Void
typealias authSuccess = (message: NSDictionary) -> Void
typealias authFail = (message: NSDictionary, error: NSError) -> Void
typealias paySuccess = (message: NSDictionary) -> Void
typealias payFail = (message: NSDictionary, error: NSError) -> Void

class RawShare : NSObject {
    
    var message: Message?
    
    // pragma mark 分享／auth以后，应用被调起，回调。
    var shareSuccessCallback: shareSuccess?
    var shareFailCallback: shareFail?
    
    var authSuccessCallback: authSuccess?
    var authFailCallback: authFail?
    
    var paySuccessCallback: paySuccess?
    var payFailCallback: payFail?
    
    var domain: String
    
    init(domain: String) {
        self.domain = domain
        super.init()
    }
    
    /**
    *  通过UIApplication打开url
    *
    *  @param url 需要打开的url
    */
    func openURL(url: String) -> Void {
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func canOpen(url: String) -> Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: url)!)
    }
    
    func prepareShare(msg:Message, success:shareSuccess, fail:shareFail) {
        reset()
        message = msg
        shareSuccessCallback = success
        shareFailCallback = fail
    }
    
    func prepareAuth(success:authSuccess, fail: authFail) {
        reset()
        authSuccessCallback = success
        authFailCallback = fail
    }
    
    func reset() {
        self.message = nil
        self.shareSuccessCallback = nil
        self.shareFailCallback = nil
        self.authSuccessCallback = nil
        self.authFailCallback = nil
        self.paySuccessCallback = nil
        self.payFailCallback = nil
    }
    
    func handleOpenURL(callbackUrl: NSURL) -> Bool {
        return false;
    }
    
    func CFBundleDisplayName() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
    }
    
    func CFBundleIdentifier() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleIdentifier") as! String
    }
    
}

class ShareManager {
    private static var schemeDomainMap: Dictionary<String, String> = Dictionary<String, String>()
    private static var domainShareMap: Dictionary<String, RawShare> = Dictionary<String, RawShare>()
    
    static func cacheShare(domain: String, schemes: [String], share: RawShare) {
        for scheme in schemes {
            schemeDomainMap[scheme] = domain
        }
        domainShareMap[domain] = share
    }
    
    static func getShare(domain domainName: String) -> RawShare? {
        return domainShareMap[domainName]
    }
    
    static func getShare(scheme schemeName: String) -> RawShare? {
        if let domain = schemeDomainMap[schemeName] {
            return getShare(domain: domain)
        }
        return nil
    }
}



