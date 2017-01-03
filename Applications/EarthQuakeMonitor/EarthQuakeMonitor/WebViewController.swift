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
    var request: URLRequest!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: "WebView", bundle: nil)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        if let request = request {
            webView.load(request)
        }
        
        view.addSubview(webView)
        view.bringSubview(toFront: activityIndicator)

        // Tell view controller that the view should be below the top bar
        edgesForExtendedLayout = UIRectEdge()
        
        pinWebViewToSuperView()
    }
    
    /**
        Pin the webview to super view with all sides constraint is constant 0.0
     */
    fileprivate func pinWebViewToSuperView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        let bottomLayout = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let topLayout = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let leadingLayout = NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailingLayout = NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
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
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("webView didCommitNavigation")
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("webView didFailNavigation")
        activityIndicator.stopAnimating()
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webView didFinishNavigation")
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            /*
            if navigationAction.navigationType == .LinkActivated {
                return
            }*/
            decisionHandler(.allow);
    }

}
