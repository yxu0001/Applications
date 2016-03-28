//
//  WKWebViewController.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 3/25/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewController: UIViewController {
    var webView: WKWebView!
    var request: NSURLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.frame)
        view = webView
        if let request = request {
            webView.loadRequest(request)
        }
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
