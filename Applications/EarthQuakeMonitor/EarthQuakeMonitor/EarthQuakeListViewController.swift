//
//  EarthQuakeListViewController.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 3/21/16.
//

import UIKit

class EarthQuakeListViewController: UITableViewController {
    
    lazy var requestMgr = RequestManager()
    var selectedFeature: QuakeFeed.Feature?
    var currentRefreshTimeInterval: FeedSummaryTimeInterval!
    
    var feed: QuakeFeed? {
        didSet {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        currentRefreshTimeInterval = .FourPointFiveDay
        refresh(self)
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        self.navigationItem.title = "Earthquakes in the Past Month"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        dispatch_async(dispatch_get_main_queue(), {
            self.refreshControl!.endRefreshing()
        })
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        if segue.identifier == "MapViewSegue" {
            guard let destinationVC = segue.destinationViewController as? MapViewController,
                selectedFeature = selectedFeature
            else {
                return
            }
            destinationVC.selectedFeature = selectedFeature
        }
    }

    
    // MARK: - Pull to refresh
    func refresh(sender: AnyObject) {
        requestMgr.fetchQuakeSummary(currentRefreshTimeInterval, completion: {
            success, feed, error in
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl!.endRefreshing()
            })
            
            if success {
                self.feed = feed
            } else {
                print(error?.description)
            }
        })
        if currentRefreshTimeInterval == .FourPointFiveDay {
            currentRefreshTimeInterval = .FourPointFiveWeek
        } else if currentRefreshTimeInterval == .FourPointFiveWeek {
            currentRefreshTimeInterval = .FourPointFiveMonth
        }
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed?.features.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath)
        cell.textLabel?.text = feed?.features[indexPath.row].properties.title
        let timestamp = feed?.features[indexPath.row].properties.time // milliseconds
        let datetime = NSDate(timeIntervalSince1970: timestamp! * 0.001)
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ "
        dateformatter.timeZone = NSTimeZone(name: "UTC")
        // set timezone
        //let tz = feed?.features[indexPath.row].properties.tz // timezone
        //let timezone = NSTimeZone(forSecondsFromGMT: tz!*60)
        //dateformatter.timeZone = timezone
        let datestring = dateformatter.stringFromDate(datetime)
        cell.detailTextLabel?.text = datestring + dateformatter.timeZone.name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let selectedFeature = feed?.features[indexPath.row] {
                //performSegueWithIdentifier("MapViewSegue", sender: self)
                if let mapNavVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MapNavController") as? UINavigationController,
                    mapVC = mapNavVC.topViewController as? MapViewController
            {
                    mapVC.selectedFeature = selectedFeature
                    splitViewController?.showDetailViewController(mapNavVC, sender: nil)
                }
        }
    }
    
}
