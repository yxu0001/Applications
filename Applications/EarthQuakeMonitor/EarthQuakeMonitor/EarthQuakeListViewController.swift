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

class EarthQuakeListViewController: UIViewController {
    
    lazy var quakeVM = EarthQuakeViewModel()
    var selectedFeature: QuakeFeed.Feature?
    var currentRefreshTimeInterval = FeedSummaryTimeInterval.AllDay
    lazy var searchController = UISearchController(searchResultsController: nil)
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBarContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //currentRefreshTimeInterval = .FourPointFiveDay
        refresh(self)
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(EarthQuakeListViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
        
        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.scopeButtonTitles = ["All", "M4.5 up"]
                
        searchBarContainerView.addSubview(searchController.searchBar)
        searchBarContainerView.layoutIfNeeded()

        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateSearchBarFrame()
    }
    
    // This method is necessary for rotation. Setting constraints does not seem to work.
    fileprivate func updateSearchBarFrame() {
        var frame = searchController.searchBar.frame
        frame.size.width = searchBarContainerView.frame.size.width
        searchController.searchBar.frame = frame
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        updateSearchBarFrame()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        DispatchQueue.main.async(execute: {
            self.refreshControl!.endRefreshing()
        })
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        if segue.identifier == "MapViewSegue" {
            
            let destinationVC = (segue.destination as! UINavigationController).topViewController as! MapViewController

            destinationVC.selectedFeature = selectedFeature
            if let features = quakeVM.feed?.features {
                let length = min(10, features.count)
                destinationVC.feeds = Array(features[0..<length])
            }
            
            destinationVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            destinationVC.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    
    // MARK: - Pull to refresh
    func refresh(_ sender: AnyObject) {
        quakeVM.fetchQuakeData(currentRefreshTimeInterval, completion: {
            [unowned self] success, error in
            DispatchQueue.main.async {
                self.refreshControl!.endRefreshing()
                self.navigationItem.title = self.navbarTitle()
                
                if self.currentRefreshTimeInterval == .AllDay {
                    self.currentRefreshTimeInterval = .AllWeek
                } else if self.currentRefreshTimeInterval == .AllWeek {
                    self.currentRefreshTimeInterval = .AllMonth
                }
                
                if success {
                    if self.isSearching() {
                        let searchBar = self.searchController.searchBar
                        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
                        self.filterContentForSearchText(searchBar.text!, scope: scope)
                    }
                    self.tableView.reloadData()
                } else {
                    print(error?.description)
                }
            }
        })
    }
    
    fileprivate func navbarTitle() -> String {
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
    
    fileprivate func isSearching() -> Bool {
        //return searchController.active && !searchController.searchBar.text!.isEmpty
        quakeVM.isSearching = searchController.isActive
        return searchController.isActive
    }
    
    // MARK: - UISearchController
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if isSearching() {
            quakeVM.filterFeaturesByDate(searchText, scope: scope)
        }
        print("filtered data begin reload")
        tableView.reloadData()
        print("filtered data end reload")
    }
}

extension EarthQuakeListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return quakeVM.numberOfSections()
    }
    
    // MARK: - UITableViewDataSource and UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quakeVM.numberOfRowsInSetion(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        
        guard let featuresByDate = quakeVM.getFeaturesByDate() else { return cell }
        let orderedKeys = featuresByDate.keys.sorted { $0.compare($1 as Date) == .orderedDescending }
        let key = orderedKeys[indexPath.section]
        guard let features = featuresByDate[key] else { return cell }
        let feature = features[indexPath.row]
        
        let textColor = colorCodedAlertLevel(feature.properties.alert)
        
        //cell.textLabel?.text = feature.properties.title
        cell.title.numberOfLines = 0
        cell.title.text = feature.properties.title
        cell.title.textColor = textColor
        let timestamp = feature.properties.time // milliseconds
        
        let datetime = Date(timeIntervalSince1970: timestamp! * 0.001)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ "
        dateformatter.timeZone = TimeZone(identifier: "UTC")
        // set timezone
        //let tz = feed?.features[indexPath.row].properties.tz // timezone
        //let timezone = NSTimeZone(forSecondsFromGMT: tz!*60)
        //dateformatter.timeZone = timezone
        let datestring = dateformatter.string(from: datetime)
        //cell.detailTextLabel?.text = datestring + dateformatter.timeZone.name
        cell.subTitle.text = datestring + dateformatter.timeZone.identifier
        cell.subTitle.textColor = textColor
        
        // Hightlight search string
        if !searchController.searchBar.text!.isEmpty {
            let baseString = cell.title.text!
            let attributed = NSMutableAttributedString(string: baseString)
            
            let regex = try? NSRegularExpression(pattern: searchController.searchBar.text!, options: .caseInsensitive)
            
            if let matches = (regex?.matches(in: baseString, options: .reportProgress, range: NSRange(location: 0, length: baseString.utf16.count)) as [NSTextCheckingResult]?) {
                for match in matches {
                    attributed.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow, range: match.range)
                }
                
                cell.title.attributedText = attributed
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let featuresByDate = quakeVM.getFeaturesByDate() else { return nil }
        let orderedKeys = featuresByDate.keys.sorted { $0.compare($1 as Date) == .orderedDescending }
        let key = orderedKeys[section]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-dd-yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        return dateFormatter.string(from: key as Date)
    }
    
    fileprivate func colorCodedAlertLevel(_ alert: AlertLevel?) -> UIColor {
        let color: UIColor
        let green = UIColor(red: 82.0/255.0, green: 127.0/255.0, blue: 19.0/255.0, alpha: 1.0)
        let yellow = UIColor.yellow
        let orange = UIColor.orange
        let red = UIColor.red
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let featuresByDate = quakeVM.getFeaturesByDate() {
            let orderedKeys = featuresByDate.keys.sorted { $0.compare($1 as Date) == .orderedDescending }
            let key = orderedKeys[indexPath.section]
            if let features = featuresByDate[key] {
                selectedFeature = features[indexPath.row]
            }
        }
        performSegue(withIdentifier: "MapViewSegue", sender: self)
    }
}

extension EarthQuakeListViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchControllerDelegate
    func presentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        updateSearchBarFrame()
    }
    
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchBar.text!, scope: scope)
    }
}

