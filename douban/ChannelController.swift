//
//  ViewController.swift
//  douban
//
//  Created by qiang wang on 14-9-14.
//  Copyright (c) 2014年 dcharm. All rights reserved.
//

import UIKit

protocol ChannelProtocal {
    func onChangeChannel(channelId:String)
}


class ChannelController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tv: UITableView!
    var channelData:NSArray = NSArray()
    var delegate:ChannelProtocal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.channelData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        let rowData:NSDictionary = self.channelData[indexPath.row] as NSDictionary
        cell.textLabel?.text = rowData["name"] as String?
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let rowData:NSDictionary = self.channelData[indexPath.row] as NSDictionary
        var s:String = rowData["channel_id"] as String
        let channelId = "channel=\(s)"
        delegate?.onChangeChannel(channelId)
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
}

