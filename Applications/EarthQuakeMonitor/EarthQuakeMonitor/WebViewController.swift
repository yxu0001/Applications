//
//  A WebViewController that uses WKWebView to load request; with an activity indicator
//  when loading.
//
//  WebViewController.swift
//
//  Created by Yijia Xu on 3/25/16.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var request: NSURLRequest!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: "WebView", bundle: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        if let request = request {
            webView.loadRequest(request)
        }
        
        view.addSubview(webView)
        view.bringSubviewToFront(activityIndicator)

        // Tell view controller that the view should be below the top bar
        edgesForExtendedLayout = .None
        
        pinWebViewToSuperView()
    }
    
    /**
        Pin the webview to super view with all sides constraint is constant 0.0
     */
    private func pinWebViewToSuperView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        let bottomLayout = NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let topLayout = NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let leadingLayout = NSLayoutConstraint(item: webView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let trailingLayout = NSLayoutConstraint(item: webView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        view.addConstraints([topLayout, bottomLayout, leadingLayout, trailingLayout])
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
            /*
            if navigationAction.navigationType == .LinkActivated {
                return
            }*/
            decisionHandler(.Allow);
    }

}
