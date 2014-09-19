
import UIKit
import MediaPlayer
import QuartzCore

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HttpProtocol, ChannelProtocal{

    @IBOutlet weak var iv: UIImageView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var pv: UIProgressView!
    @IBOutlet weak var playTime: UILabel!
    
    @IBOutlet weak var btnPlay: UIImageView!
    @IBOutlet var tap: UITapGestureRecognizer! = nil
    
    var eHttp:HttpController = HttpController()
    
    var tableData:NSArray = NSArray()
    var channelData:NSArray = NSArray()
    var imgCache = Dictionary<String, UIImage>()
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    var timer:NSTimer?
    
    func onChangeChannel(channelId: String) {
        let url = "http://douban.fm/j/mine/playlist?\(channelId)"
        //println(url)
        self.eHttp.onSearch(url)
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        if sender.view == btnPlay
        {
            btnPlay.hidden = true
            audioPlayer.play()
            btnPlay.removeGestureRecognizer(tap)
            iv.addGestureRecognizer(tap)
        }
        else if sender.view == iv
        {
            btnPlay.hidden = false
            audioPlayer.pause()
            btnPlay.addGestureRecognizer(tap)
            iv.removeGestureRecognizer(tap)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置了http的代理
        eHttp.delegate = self
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://douban.fm/j/mine/playlist?channel=0")
        self.pv.progress = 0
        iv.addGestureRecognizer(tap)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "douban");
        let rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary
        cell.textLabel?.text = rowData["title"] as String?
        cell.detailTextLabel?.text = rowData["artist"] as String?
        cell.imageView?.image = UIImage(named: "detail.jpg")
        let url = rowData["picture"] as String
        println(url)
        let img = self.imgCache[url]
        if img == nil {
            let imgUrl:NSURL = NSURL(string:url)
            let request:NSURLRequest = NSURLRequest(URL: imgUrl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (respond:NSURLResponse!, data:NSData!,error:NSError!)->Void in
                let img = UIImage(data: data)
                cell.imageView?.image = img
                self.imgCache[url] = img
            })
        }
        else {
            cell.imageView?.image = img
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let rowData:NSDictionary = self.tableData[indexPath.row] as NSDictionary
        let audioUrl = rowData["url"] as String
        let imgUrl = rowData["picture"] as String
        onSetImg(imgUrl)
        onSetAudio(audioUrl)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func didRecieveResults(results:NSDictionary)
    {
        if results.objectForKey("song") != nil {
            self.tableData = results["song"] as NSArray
            self.tv.reloadData()
            
            let firstDic:NSDictionary = self.tableData[0] as NSDictionary
            let audioUrl = firstDic["url"] as String
            let imgUrl = firstDic["picture"] as String
            onSetAudio(audioUrl)
            onSetImg(imgUrl)
        }
        else if results.objectForKey("channels") != nil{
            self.channelData = results["channels"] as NSArray
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var channelControl:ChannelController = segue.destinationViewController as ChannelController
        channelControl.delegate = self
        channelControl.channelData = self.channelData
    }
    
    func onSetAudio(url:String)
    {
        timer?.invalidate()
        playTime.text = "00:00"
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string:url)
        self.audioPlayer.play()
        timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        btnPlay.removeGestureRecognizer(tap)
        iv.addGestureRecognizer(tap)
        btnPlay.hidden = true
    }
    
    func onUpdate()
    {
        let c = audioPlayer.currentPlaybackTime
        if c > 0{
            let t = audioPlayer.duration
            let p:CFloat = CFloat(c/t)
            pv.setProgress(p, animated: true)
            
            let second = Int(c) % 60
            let minute = Int(c) / 60
            var timeStr = ""
            if minute < 10
            {
                timeStr = "0\(minute):"
            }
            else
            {
                timeStr = "\(minute):"
            }
            if second < 10 {
                timeStr += "0\(second)"
            }
            else
            {
                timeStr += "\(second)"
            }
            playTime.text = timeStr
        }
        
    }
    
    func onSetImg(url:String)
    {
        let img = self.imgCache[url] as UIImage?
        if img == nil {
            let imgUrl:NSURL = NSURL(string:url)
            let request:NSURLRequest = NSURLRequest(URL: imgUrl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (respond:NSURLResponse!, data:NSData!,error:NSError!)->Void in
                let img = UIImage(data: data)
                self.iv.image = img
                self.imgCache[url] = img
            })
        }
        else {
             self.iv.image = img
        }
    }

}

