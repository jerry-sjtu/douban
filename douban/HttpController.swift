//
//  HttpController.swift
//  douban
//
//  Created by qiang wang on 14-9-14.
//  Copyright (c) 2014年 dcharm. All rights reserved.
//

import UIKit

protocol HttpProtocol{
    func didRecieveResults(results:NSDictionary)
}

class HttpController:NSObject {
    
    var delegate:HttpProtocol?
    
    func onSearch(url:String)
    {
        var nsUrl:NSURL = NSURL(string: url)
        var request:NSURLRequest = NSURLRequest(URL: nsUrl)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (respond:NSURLResponse!, data:NSData!,error:NSError!)->Void in
            var jsonReulst:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error:nil) as NSDictionary
            self.delegate?.didRecieveResults(jsonReulst)
        })
    }
}
