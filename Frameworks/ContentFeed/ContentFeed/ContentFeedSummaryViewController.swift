//
//  ContentFeedSummaryViewController.swift
//  ContentFeed
//
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit
import WebKit

// Note: Did not use SFSafariViewController for 2 reasons:
//      1) As per SFSafariViewController doc, the guidelines for choosing web view class is:
//         " Use the SFSafariViewController class if your app lets users view websites from anywhere on the Internet. 
//         Use the WKWebView class if your app customizes, interacts with, or controls the display of web content."
//         ContentFeed use case fits the WKWebView use case.
//      2) Need to support iOS 8.0, where SafariServices is not available
class ContentFeedSummaryViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView?
    var viewModel: ContentFeedCellViewModel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var selectedRequest: NSURLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(viewModel?.contentURL)
        
        webView = WKWebView(frame: view.frame)
        if let webView = webView {
            webView.navigationDelegate = self
            view.addSubview(webView)
            webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        }

        view.bringSubviewToFront(activityIndicator)
        
        if let contentURL = viewModel?.contentURL {
            let request = NSURLRequest(URL: contentURL)
            webView?.loadRequest(request)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ContentFeedDetails" {
            guard let destinationNavVC = segue.destinationViewController as? UINavigationController,
                destinationVC = destinationNavVC.viewControllers[0] as? ContentFeedDetailViewController
            else { return }
            
            destinationVC.request = selectedRequest
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        print("webView didCommitNavigation")
        activityIndicator.startAnimating()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print("webView didFailNavigation")
        activityIndicator.stopAnimating()
    }
    
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("webView didFinishNavigation")
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .LinkActivated {
                selectedRequest = navigationAction.request
                performSegueWithIdentifier("ContentFeedDetails", sender: self)
                decisionHandler(.Cancel);
                return
            }
            decisionHandler(.Allow);
    }
}
