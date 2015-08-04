//
//  ViewController.swift
//  share
//
//  Created by  lifirewolf on 15/7/29.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let testFile = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("test", ofType: "pdf")!)
    let testImage = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("logo", ofType: "png")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func shareWeChat(sender: UIButton) {
        
        if let share = ShareManager.getShare(domain: RSWeChat.domain) as? RSWeChat {

            share.shareToWeChatSession(self.wcMsg(1),
                success: { message in println("success")},
                fail: { message, error in
                    println("fail")
                    println(error)
                }
            )
        }
    }
    
    @IBAction func weChatAuth(sender: UIButton) {
        
        if let share = ShareManager.getShare(domain: RSWeChat.domain) as? RSWeChat {
            
            share.weChatAuth(
                {message in println("success")},
                fail: { message, error in
                    println("fail")
                    println(error)
                }
            )
        }
    }
    
    @IBAction func weChatPay(sender: UIButton) {
        
        let apiUrl: String = "https://pay.example.com/pay.php?payType=weixin"
        
        //网络请求不要阻塞UI，仅限Demo
        let data: NSData = NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: NSURL(string: apiUrl)!), returningResponse:nil, error:nil)!
        
        let link = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        if let share = ShareManager.getShare(domain: RSWeChat.domain) as? RSWeChat {
            
            share.weChatPay("\(link)",
                success: {message in println("success")},
                fail: { message, error in
                    println("fail")
                    println(error)
                }
            )
        }
    }
    
    func wcMsg(tag: Int) -> Message {
        var msg: Message = Message()
        msg.title = "Hello msg.title"
        
        if tag > 1 {
            msg.desc = "这里是msg.desc"
        }
        
        if tag == 2 {
            //图片
            msg.image = testImage
            msg.thumbnail = testImage
        } else if tag == 3 {
            //link
            msg.link = "http://tech.qq.com/zt2012/tmtdecode/252.htm"
            msg.image = testImage //新闻类型的职能传缩略图就够了。
        } else if tag == 4 {
            //Music
            msg.mediaDataUrl = "http://stream20.qqmusic.qq.com/32464723.mp3"
            msg.link = "http://tech.qq.com/zt2012/tmtdecode/252.htm"
            msg.thumbnail = testImage
            msg.messageType = .Audio
        } else if tag == 5 {
            //video
            msg.link = "http://v.youku.com/v_show/id_XNTUxNDY1NDY4.html"
            msg.thumbnail = testImage
            msg.messageType = .Video
        } else if tag == 6 {
            //app
            msg.extInfo = "app自己的扩展消息，当从微信打开app的时候，会传给app"
            msg.link = "http://www.baidu.com/"  //分享到朋友圈以后，微信就不会调用app了，跟news类型分享到朋友圈一样。
            msg.image = testImage
            msg.thumbnail = testImage
            msg.messageType = .App
        } else if tag == 7 {
            //非gif表情／同图片。
            msg.image = testImage
            msg.thumbnail = testImage
        } else if tag == 8 {
            //gif表情／同图片，只是格式是gif。
            msg.image = testImage
            msg.thumbnail = testImage
        } else if tag == 9 {
            //file
            msg.image = testFile
            msg.thumbnail = testImage
            msg.title = "test.pdf"   //添加到收藏的时候，微信会根据文件名打开。fileExt信息丢失。微信的bug
            msg.fileExt = "pdf"
            msg.messageType = .File
        }
        
        return msg
    }
    
    @IBAction func shareQQ(sender: UIButton) {
        println("start share to QQ")
        
        if let share = ShareManager.getShare(domain: RSQQ.domain) as? RSQQ {
            
            share.shareToQQFriends(self.qqMsg(0),
                success: { message in println("success")},
                fail: { message, error in
                    println("fail")
                    println(error)
                }
            )
        }
    }
    
    @IBAction func qqAuth(sender: UIButton) {
        if let share = ShareManager.getShare(domain: RSQQ.domain) as? RSQQ {
            
            share.qqAuth("get_user_info",
                success: { message in println("success")},
                fail: { message, error in
                    println("fail")
                    println(error)
                }
            )
        }
    }
    
    func qqMsg(tag: Int) -> Message {
        var msg: Message = Message()
        msg.title = "Hello msg.title"
        
        if tag >= 2 {
            msg.image = testImage
            msg.thumbnail = msg.image
            msg.desc = "这里写的是msg.description";
        }
        
        if tag == 3 {
            msg.link = "http://sports.qq.com/a/20120510/000650.htm"
        } else if tag == 4 {
            msg.link = "http://wfmusic.3g.qq.com/s?g_f=0&fr=&aid=mu_detail&id=2511915"
            msg.messageType = .Audio
        } else if tag == 5 {
            msg.link = "http://v.youku.com/v_show/id_XOTU2MzA0NzY4.html"
            msg.messageType = .Video
        }
        
        return msg
    }

    @IBAction func shareWeibo(sender: UIButton) {
        if let share = ShareManager.getShare(domain: RSWeibo.domain) as? RSWeibo {

            share.shareToWeibo(self.wbMsg(2),
                success: { message in println("success")},
                fail: { message, error in
                    println("fail")
                    println(error)
                }
            )
        }
    }
    
    @IBAction func weiboAuth(sender: UIButton) {
        if let share = ShareManager.getShare(domain: RSWeibo.domain) as? RSWeibo {
            
            share.weiboAuth("http://openshare.gfzj.us/",
                success: { message in self.ULog("", msg: message)},
                fail: { message, error in
                    println("fail")
                    println(error)
                }
            )
        }
    }
    
    func wbMsg(tag: Int) -> Message {
        var msg: Message = Message()
        msg.title = "Hello msg.title"
        
        if tag >= 2 {
            // 图片
            msg.image = testImage
        }
        
        if tag == 3 {
            // 新闻
            msg.link = "http://openshare.gfzj.us/"
        }
        
        return msg
    }

    @IBAction func aliPay(sender: UIButton) {
        let apiUrl: String = "https://pay.example.com/pay.php?payType=weixin"
        
        //网络请求不要阻塞UI，仅限Demo
        let data: NSData = NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: NSURL(string: apiUrl)!), returningResponse:nil, error:nil)!
        
        let link = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        if let share = ShareManager.getShare(domain: RSAliPay.domain) as? RSAliPay {
            
            share.aliPay("\(link)",
                success: {message in self.ULog("AliPay Success", msg: message)},
                fail: { message, error in self.ULog("AliPay fail", msg: message)}
            )
        }
    }
    
    func ULog(title: String?, msg: AnyObject?) {
        let alert = UIAlertView(title: title, message: msg != nil ? "\(msg!)" : nil, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        
    }
}

