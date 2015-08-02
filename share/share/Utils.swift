//
//  Utils.swift
//  share
//
//  Created by  lifirewolf on 15/7/31.
//  Copyright (c) 2015年  lifirewolf. All rights reserved.
//

import UIKit

class Utils {
    
    /**
    粘贴板数据编码方式，目前只有两种:
    1. [NSKeyedArchiver archivedDataWithRootObject:data];
    2. [NSPropertyListSerialization dataWithPropertyList:data format:NSPropertyListBinaryFormat_v1_0 options:0 error:&err];
    */
    enum PasteboardEncoding {
        case KeyedArchiver
        case PropertyListSerialization
    }
    
    static func parseUrl(url: NSURL) -> Dictionary<String, String> {
        
        var dic = Dictionary<String, String>()
        
        if let urlComponents: [String] = url.query?.componentsSeparatedByString("&") {
        
            for keyValuePair in urlComponents {
                if let range = keyValuePair.rangeOfString("=") {
                
                    let key = keyValuePair[keyValuePair.startIndex..<range.startIndex]
                    let value = keyValuePair[range.endIndex..<keyValuePair.endIndex]
                    
                    dic[key] = value
                }
            }
        }
        return dic;
    }
    
    static func base64Encode(input: String) -> String {
        return input.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
    }
    
    static func base64Decode(input: String) -> String {
        let rst = NSString(data: NSData(base64EncodedString: input, options: NSDataBase64DecodingOptions.allZeros)!, encoding: NSUTF8StringEncoding)
        
        return "\(rst)"
    }
    
    static func base64AndUrlEncode(string: String) -> String {
        
        return base64Encode(string).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
    
    static func urlDecode(string: String) -> String {
        
        return string.stringByReplacingOccurrencesOfString("+", withString: "").stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    static func setGeneralPasteboard(key: String?, value: Dictionary<String, AnyObject>?, encoding: PasteboardEncoding) -> Void {
        
        if value != nil && key != nil {
            var data: NSData?
            var error: NSError?
            
            switch (encoding) {
            case .KeyedArchiver :
                data = NSKeyedArchiver.archivedDataWithRootObject(value!)
            case .PropertyListSerialization :
                data = NSPropertyListSerialization.dataWithPropertyList(value!, format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0, error: &error)
            default : NSLog("encoding not implemented");
            }
            
            if error != nil {
                NSLog("error when NSPropertyListSerialization: \(error)");
            } else if data != nil {
                UIPasteboard.generalPasteboard().setData(data!, forPasteboardType: key!)
            }
        }
        
    }
    
    static func generalPasteboardData(key: String, encoding: PasteboardEncoding) -> Dictionary<String, AnyObject>? {
        
        let data: NSData? = UIPasteboard.generalPasteboard().dataForPasteboardType(key)
        var dic: Dictionary<String, AnyObject>?
        if data != nil {
            var err: NSError?
            switch (encoding) {
            case .KeyedArchiver :
                dic = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? Dictionary<String, AnyObject>
            case .PropertyListSerialization :
                dic = NSPropertyListSerialization.propertyListWithData(data!, options: 0, format: nil, error: &err) as? Dictionary<String, AnyObject>
            default : break
            }
            if err != nil {
                NSLog("error when NSPropertyListSerialization: \(err)");
            }
        }
        
        return dic;
    }
    
    /**
    *  截屏功能。via：http://stackoverflow.com/a/8017292/3825920
    */
    static func screenshot() -> UIImage {
        
        var imageSize: CGSize = CGSizeZero
        
        var orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        if UIInterfaceOrientationIsPortrait(orientation) {
            imageSize = UIScreen.mainScreen().bounds.size
        } else {
            imageSize = CGSizeMake(UIScreen.mainScreen().bounds.size.height, UIScreen.mainScreen().bounds.size.width)
        }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        
        var context: CGContextRef = UIGraphicsGetCurrentContext()
        
        for window in UIApplication.sharedApplication().windows {
            CGContextSaveGState(context)
            CGContextTranslateCTM(context, window.center.x, window.center.y)
            CGContextConcatCTM(context, window.transform)
            CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y)
            if (orientation == UIInterfaceOrientation.LandscapeLeft) {
                CGContextRotateCTM(context, CGFloat(M_PI_2))
                CGContextTranslateCTM(context, 0, -imageSize.width);
            } else if (orientation == UIInterfaceOrientation.LandscapeRight) {
                CGContextRotateCTM(context, CGFloat(-M_PI_2))
                CGContextTranslateCTM(context, -imageSize.height, 0)
            } else if (orientation == UIInterfaceOrientation.PortraitUpsideDown) {
                CGContextRotateCTM(context, CGFloat(M_PI))
                CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
            }
            
            if window.respondsToSelector(Selector("drawViewHierarchyInRect:afterScreenUpdates:")) {
                window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates:true)
            } else {
                window.layer.renderInContext(context)
            }
            CGContextRestoreGState(context)
            
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image;
    }
    
    static func createUUID() -> String {
        let uuidObj: CFUUIDRef = CFUUIDCreate(nil)
        let cfUUID: CFString = CFUUIDCreateString(nil, uuidObj)
        
        return "\(cfUUID)"
    }
    
}