//
//  ContentFeedListViewController.swift
//  ContentFeed
//
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit

@objc public protocol ContentFeedListViewControllerDelegate {
    optional func showHome(animated: Bool)
}

public class ContentFeedListCell: UITableViewCell {
    let bullet = "•"
    
    // binding to the view model
    var viewModel: ContentFeedCellViewModel? {
        didSet {
            guard let vm = viewModel else {return}
            self.titleLabel.text = vm.title
            self.subjectLabel.text = vm.subtitle
            self.dateSourceLabel.text = vm.receivedLapseTime + " " + bullet + " " + vm.source
            //self.readUnreadImgView.hidden = vm.read
            self.readUnreadImgView.hidden = true // the read/unread indicator is hidden for first release.
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var dateSourceLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var readUnreadImgView: UIImageView!
}

public class ContentFeedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    public weak var delegate: ContentFeedListViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstLaunchView: UIView!
    
    
    @IBOutlet weak var networkView: UIView!
    @IBOutlet weak var networkViewHeight: NSLayoutConstraint!
    @IBOutlet weak var networkViewTop: NSLayoutConstraint!
    
    lazy var requestMgr = RequestManager()
    lazy var refreshControl = UIRefreshControl()
    
    var listVM: ContentFeedListViewModel?
    var selectedViewModel: ContentFeedCellViewModel?
    var firstLaunchViewShown: Bool = false
    var firstLaunchViewIsShowing: Bool = false

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listVM = ContentFeedListViewModel()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        // network view: whether network is accessible
        networkViewTop.constant = -networkViewHeight.constant
        self.view.bringSubviewToFront(networkView)
        
        // This is tentative. Server work in progress
        let config = Config(regproBaseURL: "http://regdmdv700.athenahealth.com:8080", regproEndpoint: "", regproPath: "appsvr/secured/contentfeed/dummy/3", mdpPath: "", servicesBaseURL: "")
        requestMgr.config = config
        
        refresh(self)
        
        // Pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
    }

    /**
        Pull to refresh action
        - parameter sender: AnyObject
     */
    func refresh(sender: AnyObject) {
        requestMgr.getContentFeedItems(20, completion: {
            (success, data, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.refreshControl.endRefreshing()
            })
            if let error = error where error.code == NSURLErrorNotConnectedToInternet ||
                                       error.code == NSURLErrorTimedOut ||
                                       error.code == NSURLErrorBadServerResponse {
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateNetworkViewConstraints(shouldShow: true)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateNetworkViewConstraints(shouldShow: false)
                })
            }
        })
    }
    
    public override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        super.viewDidAppear(animated)
        
        // show first launch view if should show
        if shouldShowFirstLaunchView() {
            view.layoutIfNeeded()
            UIView.animateWithDuration(1.0, animations: {
                self.updateConstraints(true)
                self.view.layoutIfNeeded()
                }, completion: {compelted in
                    self.firstLaunchViewShown = true
                    self.firstLaunchViewIsShowing = true
            })
        }
    }
        
    /**
        Whether should show the first launch view (the view to tell user this is a beta).
        Currently this logic only checks firstLaunchViewShown and firstLaunchViewIsShowing flags
        in memory. This logic will need to be modified to check some value persisted in preference.
        - returns: should show or not Bool
     */
    private func shouldShowFirstLaunchView() -> Bool {
        if !firstLaunchViewShown && !firstLaunchViewIsShowing {
            return true
        }
        return false
    }
    
    /**
        Update the constraint of the tableview and first launch view. Mainly update the priorites of
        the tableview top constraint and its value. The priority was set to UILayoutPriorityDefaultHigh (750)
        initially. 
        - parameter shouldShow: Bool whether should show the first launch view
     */
    private func updateConstraints(shouldShow: Bool) {
        if shouldShow {
            self.tableViewTopConstraint.priority = UILayoutPriorityDefaultHigh + 1
            self.tableViewTopConstraint.constant = self.firstLaunchView.frame.size.height
        } else {
            self.tableViewTopConstraint.priority = UILayoutPriorityDefaultHigh - 1
            self.tableViewTopConstraint.constant = 0
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        // end refresh before the view controller is going away
        refreshControl.endRefreshing()
    }
    
    // MARK: - Bar button actions
    @IBAction func homeTapped(sender: AnyObject) {
        delegate?.showHome?(true)
    }

    @IBAction func feedbackTapped(sender: AnyObject) {
    }
    
    /**
        Realizing animation of the network view via updating the constraints.
        When the view is showing, its top to top layout guide is set to be 0.
        When the view is hiding, its top to top layout guide is set to be negative its height. Then
        the view will be hidden behind the nav bar.
        - parameter shouldShow: Bool whether the network view should show
     */
    private func updateNetworkViewConstraints(shouldShow shouldShow: Bool) {
        if shouldShow {
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.networkViewTop.constant = 0.0
                self.networkView.layoutIfNeeded()
                }, completion: { completed in })
        } else {
            UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
                self.networkViewTop.constant = -self.networkViewHeight.constant
                self.networkView.layoutIfNeeded()
                }, completion: { completed in })
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ContentFeedSummary" {
            guard let destinationVC = segue.destinationViewController as? ContentFeedSummaryViewController else { return }
            destinationVC.viewModel = selectedViewModel
        }
    }

    // MARK: - UITableViewDataSource
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listVM?.itemCount() ?? 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = configureCell(tableView, cellForRowAtIndexPath: indexPath)
        return cell
    }
    
    
    /**
        Configuration of the cell. Use cell reusable identifier "ContentFeedNoImageCell" for cells with no image; "ContentFeedImageCell" for cell with image.
        - parameter tableView: UITableView
        - parameter cellForRowAtIndexPath: NSIndexPath
        - returns: UITableViewCell
     */
    private func configureCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ContentFeedNoImageCell", forIndexPath: indexPath) as! ContentFeedListCell

        if let vm = listVM?.viewModel(forIndexPath: indexPath) {
            if vm.hasImage {
                cell = tableView.dequeueReusableCellWithIdentifier("ContentFeedImageCell", forIndexPath: indexPath) as! ContentFeedListCell
                
                // Request for the image data. This process can get complicated as to involve in request cancellation,
                // image cache managment. For ContentFeed, it appears for now (03/01/2016) can do without image caching.
                // There is code attempt to cancel the request if the cell has been scrolled out of the visible area
                // after imageLoadingTask.resume(). 
                // If needed can use existing github frameworks such as Kingfisher or SDWebImage, which handles more
                // complicated use cases.
                cell.imgView.image = nil
                let imageLoadingTask = NSURLSession.sharedSession().dataTaskWithURL(vm.imageURL!, completionHandler: {
                    (data, response, error) in
                    if let data = data,
                        image = UIImage(data: data) {
                            dispatch_async(dispatch_get_main_queue(), {
                                if let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? ContentFeedListCell {
                                    updateCell.imgView.image = image
                                    updateCell.setNeedsDisplay()
                                    updateCell.layoutIfNeeded()
                                }
                            })
                    } else {
                        // show image cannot be found
                    }
                })
                // If the cell has been scrolled out of the visible area, cancel the request to get image.
                if let visibleRows = tableView.indexPathsForVisibleRows where !visibleRows.contains(indexPath) {
                    print("cancelling imageLoadingTask")
                    imageLoadingTask.cancel()
                } else {
                    imageLoadingTask.resume()
                }
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("ContentFeedNoImageCell", forIndexPath: indexPath) as! ContentFeedListCell
            }
            cell.viewModel = vm
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected indexPath.row = \(indexPath.row)")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedViewModel = listVM?.viewModel(forIndexPath: indexPath)
        performSegueWithIdentifier("ContentFeedSummary", sender: self)
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        // hide the first launch view if user begins to scroll
        if firstLaunchViewIsShowing {
            view.layoutIfNeeded()
            UIView.animateWithDuration(1.0, animations: {
                self.updateConstraints(false)
                self.view.layoutIfNeeded()
                }, completion: {compelted in
                    self.firstLaunchViewShown = true
                    self.firstLaunchViewIsShowing = false
            })
        }
    }
}
