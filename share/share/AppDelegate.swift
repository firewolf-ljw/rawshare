//
//  AppDelegate.swift
//  share
//
//  Created by  lifirewolf on 15/7/29.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    struct ShareIdentity {
        static let WeChatAppId: String = "wxd930ea5d5a258f4f"
        static let QQAppId: String = "1103194207"
        static let WeiboAppKey: String = "402180334"
        static let AliPayCallBack: String = "rawshare"
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        swizzle()
        
        RSWeChat.register(ShareIdentity.WeChatAppId)
        RSQQ.register(ShareIdentity.QQAppId)
        RSWeibo.register(ShareIdentity.WeiboAppKey)
        RSAliPay.register(ShareIdentity.AliPayCallBack)
        
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        if let share = ShareManager.getShare(scheme: url.scheme!) {
            return share.handleOpenURL(url)
        }
        
        return false
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func swizzle() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
    
        dispatch_once(&Static.token) {
            let originalSelector = Selector("openURL:")
            let swizzledSelector = Selector("hook_openURL:")
            
            let originalMethod: IMP = UIApplication.instanceMethodForSelector(originalSelector)
            let swizzledMethod = UIApplication.instanceMethodForSelector(swizzledSelector)
            
            class_replaceMethod(UIApplication.self, originalSelector, swizzledMethod, nil)
            class_replaceMethod(UIApplication.self, swizzledSelector, originalMethod, nil)
            
        }
    }
    
}

extension UIApplication {
    func hook_openURL(url: NSURL) -> Bool {
        println("hooking open url: \(url)")
        return self.hook_openURL(url)
    }
}
