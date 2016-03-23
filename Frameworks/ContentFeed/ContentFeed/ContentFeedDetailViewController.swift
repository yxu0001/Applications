//
//  ContentFeedDetailViewController.swift
//  ContentFeed
//
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit
import WebKit

class ContentFeedDetailViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var request: NSURLRequest?
    @IBOutlet weak var webViewContainer: UIView!
    
    @IBOutlet weak var prevButton: UIBarButtonItem!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print(request)
        
        webView = WKWebView(frame: CGRectMake(0.0, 0.0, webViewContainer.frame.height, webViewContainer.frame.width))
        if let webView = webView {
            webView.navigationDelegate = self
            webViewContainer.addSubview(webView)
            webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        }
        view.bringSubviewToFront(activityIndicator)
        
        if let request = request,
            webView = webView {
            webView.loadRequest(request)
        }
        prevNextButtonState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func prevNextButtonState() {
        guard let webView = webView else { return }
        prevButton.enabled = webView.canGoBack
        nextButton.enabled = webView.canGoForward
    }
    
    // MARK: - WebView ToolBar action
    @IBAction func dismissTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

    @IBAction func prevButtonTapped(sender: AnyObject) {
        guard let webView = webView else { return }
        webView.goBack()
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        guard let webView = webView else { return }
        webView.goForward()
    }

    // There is no refresh bar button
    /*
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        guard let webView = webView else { return }
        webView.reload()
    }*/
    
    @IBAction func feedbackTapped(sender: AnyObject) {
        // placeholder for feedback action
    }
    
    @IBAction func shareTapped(sender: AnyObject) {
        print("shareTapped")
        guard let url = request?.URL else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        let excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo]
        activityVC.excludedActivityTypes = excludedActivityTypes
        activityVC.completionWithItemsHandler = {
            (activityType, completed, returnedItems, activityError) in
            // Common Logging goes here
            print(activityType)
            print("Completed = " + (completed ? "true" : "fasle"))
            if let returnedItems = returnedItems {
                print("returnedItems = \(returnedItems.count)")
            }
            if let error = activityError {
                print("activityError = " + error.description)
            }
        }
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        prevNextButtonState()
    }
    
    func webView(webView: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
        decisionHandler: (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.Allow);
    }
    

}
