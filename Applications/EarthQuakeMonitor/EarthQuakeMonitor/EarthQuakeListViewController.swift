//
//  EarthQuakeListViewController.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 3/21/16.
//

import UIKit

class FeedCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
}

class EarthQuakeListViewController: UITableViewController {
    
    lazy var requestMgr = RequestManager()
    var selectedFeature: QuakeFeed.Feature?
    var currentRefreshTimeInterval: FeedSummaryTimeInterval!
    lazy var searchController = UISearchController(searchResultsController: nil)
    var filtered: [QuakeFeed.Feature]?
    
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
        
        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
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
            [unowned self] success, feed, error in
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControl!.endRefreshing()
                self.navigationItem.title = self.navbarTitle()
                if self.currentRefreshTimeInterval == .FourPointFiveDay {
                    self.currentRefreshTimeInterval = .FourPointFiveWeek
                } else if self.currentRefreshTimeInterval == .FourPointFiveWeek {
                    self.currentRefreshTimeInterval = .FourPointFiveMonth
                }
            }
            
            if success {
                self.feed = feed
            } else {
                print(error?.description)
            }
        })

    }
    
    private func navbarTitle() -> String {
        var title = "Earthquakes in the Past "
        if currentRefreshTimeInterval == .FourPointFiveDay {
            title += "Day"
        } else if currentRefreshTimeInterval == .FourPointFiveWeek {
            title += "Week"
        } else if currentRefreshTimeInterval == .FourPointFiveMonth {
            title += "Month"
        } else {
            title = "Earthquaks"
        }
        return title
    }
    
    private func isSearching() -> Bool {
        return searchController.active && !searchController.searchBar.text!.isEmpty
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching() {
            return filtered?.count ?? 0
        }
        
        return feed?.features.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedCell
        let feature: QuakeFeed.Feature?
        if isSearching() {
            feature = filtered?[indexPath.row]
        } else {
            feature = feed?.features[indexPath.row]
        }
        
        if let feature = feature {
            let textColor = colorCodedAlertLevel(feature.properties.alert)
            
            //cell.textLabel?.text = feature.properties.title
            cell.title.numberOfLines = 0
            cell.title.text = feature.properties.title
            cell.title.textColor = textColor
            let timestamp = feature.properties.time // milliseconds
            
            let datetime = NSDate(timeIntervalSince1970: timestamp! * 0.001)
            let dateformatter = NSDateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ "
            dateformatter.timeZone = NSTimeZone(name: "UTC")
            // set timezone
            //let tz = feed?.features[indexPath.row].properties.tz // timezone
            //let timezone = NSTimeZone(forSecondsFromGMT: tz!*60)
            //dateformatter.timeZone = timezone
            let datestring = dateformatter.stringFromDate(datetime)
            //cell.detailTextLabel?.text = datestring + dateformatter.timeZone.name
            cell.subTitle.text = datestring + dateformatter.timeZone.name
            cell.subTitle.textColor = textColor
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    private func colorCodedAlertLevel(alert: AlertLevel?) -> UIColor {
        let color: UIColor
        let green = UIColor(red: 82.0/255.0, green: 127.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        let yellow = UIColor.yellowColor()
        let orange = UIColor.orangeColor()
        let red = UIColor.redColor()
        
        if let alert = alert {
            switch(alert) {
            case .green:
                color = green
            case .yellow:
                color = yellow
            case .orange:
                color = orange
            case .red:
                color = red
            }
        } else {
            color = green
        }
        
        return color
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let selectedFeature: QuakeFeed.Feature!
        if isSearching() {
            selectedFeature = filtered?[indexPath.row]
        } else {
            selectedFeature = feed?.features[indexPath.row]
        }
        if let selectedFeature = selectedFeature {
                //performSegueWithIdentifier("MapViewSegue", sender: self)
                if let mapNavVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MapNavController") as? UINavigationController,
                    mapVC = mapNavVC.topViewController as? MapViewController
            {
                    mapVC.selectedFeature = selectedFeature
                    splitViewController?.showDetailViewController(mapNavVC, sender: nil)
                }
        }
    }
    
    // MARK: - UISearchController
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filtered = feed?.features.filter { feature in
            return feature.properties.title.lowercaseString.containsString(searchText.lowercaseString)
        }
    }
}

extension EarthQuakeListViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchControllerDelegate
    func presentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(__FUNCTION__).")
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
}
