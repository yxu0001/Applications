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
    
    lazy var quakeVM = EarthQuakeViewModel()
    var selectedFeature: QuakeFeed.Feature?
    var currentRefreshTimeInterval = FeedSummaryTimeInterval.AllDay
    lazy var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //currentRefreshTimeInterval = .FourPointFiveDay
        refresh(self)
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(EarthQuakeListViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.scopeButtonTitles = ["All", "M4.5 up"]
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
            
            let destinationVC = (segue.destinationViewController as! UINavigationController).topViewController as! MapViewController

            destinationVC.selectedFeature = selectedFeature
            if let features = quakeVM.feed?.features {
                let length = min(10, features.count)
                destinationVC.feeds = Array(features[0..<length])
            }
            
            destinationVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
            destinationVC.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    
    // MARK: - Pull to refresh
    func refresh(sender: AnyObject) {
        quakeVM.fetchQuakeData(currentRefreshTimeInterval, completion: {
            [unowned self] success, error in
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControl!.endRefreshing()
                self.navigationItem.title = self.navbarTitle()
                
                if self.currentRefreshTimeInterval == .AllDay {
                    self.currentRefreshTimeInterval = .AllWeek
                } else if self.currentRefreshTimeInterval == .AllWeek {
                    self.currentRefreshTimeInterval = .AllMonth
                }
                
                if success {
                    self.tableView.reloadData()
                } else {
                    print(error?.description)
                }
            }
            })
    }
    
    private func navbarTitle() -> String {
        var title = "Earthquakes in the Past "
        switch currentRefreshTimeInterval {
        case .AllDay:
            title += "Day"
        case .AllWeek:
            title += "Week"
        case .AllMonth:
            title += "Month"
        default:
            title = "Earthquakes"
        }
        
        
        return title
    }
    
    private func isSearching() -> Bool {
        //return searchController.active && !searchController.searchBar.text!.isEmpty
        quakeVM.isSearching = searchController.active
        return searchController.active
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return quakeVM.numberOfSections()
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quakeVM.numberOfRowsInSetion(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedCell
        
        guard let featuresByDate = quakeVM.getFeaturesByDate() else { return cell }
        let orderedKeys = featuresByDate.keys.sort { $0.compare($1) == .OrderedDescending }
        let key = orderedKeys[indexPath.section]
        guard let features = featuresByDate[key] else { return cell }
        let feature = features[indexPath.row]
        
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
        
        // Hightlight search string
        let baseString = cell.title.text!
        let attributed = NSMutableAttributedString(string: baseString)
        
        let regex = try? NSRegularExpression(pattern: searchController.searchBar.text!, options: .CaseInsensitive)
        
        if let matches = (regex?.matchesInString(baseString, options: .ReportProgress, range: NSRange(location: 0, length: baseString.utf16.count)) as [NSTextCheckingResult]?) {
            for match in matches {
                attributed.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellowColor(), range: match.range)
            }
            
            cell.title.attributedText = attributed
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let featuresByDate = quakeVM.getFeaturesByDate() else { return nil }
        let orderedKeys = featuresByDate.keys.sort { $0.compare($1) == .OrderedDescending }
        let key = orderedKeys[section]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM-dd-yyyy"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        
        return dateFormatter.stringFromDate(key)
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
        
        if let featuresByDate = quakeVM.getFeaturesByDate() {
            let orderedKeys = featuresByDate.keys.sort { $0.compare($1) == .OrderedDescending }
            let key = orderedKeys[indexPath.section]
            if let features = featuresByDate[key] {
                selectedFeature = features[indexPath.row]
            }
        }
        performSegueWithIdentifier("MapViewSegue", sender: self)
    }
    
    // MARK: - UISearchController
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        if isSearching() {
            if searchText.isEmpty {
                if scope == "All" {
                    quakeVM.filtered = quakeVM.feed?.features
                } else if scope == "M4.5 up" {
                    quakeVM.filtered = quakeVM.feed?.features.filter{ feature in return feature.properties.mag >= 4.5 }
                }
            } else {
                if scope == "All" {
                    quakeVM.filtered = quakeVM.feed?.features.filter { feature in
                        return feature.properties.title.lowercaseString.containsString(searchText.lowercaseString)
                    }
                } else if scope == "M4.5 up" {
                    quakeVM.filtered = quakeVM.feed?.features.filter { feature in
                        return (feature.properties.mag >= 4.5) && feature.properties.title.lowercaseString.containsString(searchText.lowercaseString)
                    }
                }
            }
        }
        tableView.reloadData()
    }
}

extension EarthQuakeListViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchControllerDelegate
    func presentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

