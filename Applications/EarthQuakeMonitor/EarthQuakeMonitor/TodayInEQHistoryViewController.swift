//
//  TodayInEQHistoryViewController.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 3/25/16.
//

import UIKit

class TodayInEQHistoryViewController: WebViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        request = NSURLRequest(URL: NSURL(string: "http://earthquake.usgs.gov/learn/today/")!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 3600)
        //request = NSURLRequest(URL: NSURL(string: "http://sfgate.com")!, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 3600)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
