//
//  ContentFeedViewControllerFactory.swift
//  ContentFeed
//
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit

public class ContentFeedViewControllerFactory : NSObject {
    
    /**
        Get the entry view controller of ContentFeed.storyboard. It should be a
        UINavigationController.
        - returns: UINavigationController? contentFeedNavViewController
     */
    public class func contentFeedNavViewController() -> UINavigationController? {
        
        let storyboard = UIStoryboard(name: "ContentFeed", bundle: NSBundle(forClass: ContentFeedViewControllerFactory.self))
        let contentFeedNavVC = storyboard.instantiateInitialViewController() as? UINavigationController
        
        return contentFeedNavVC
    }
    
    /**
        Get the ContentFeedListViewController, which is the root view controller of the
        ContentFeed.storyboard entry VC (a UINavigationController).
        - returns: UIViewController? contentFeedListViewController
     */
    public class func contentFeedListViewController() -> UIViewController? {
        let storyboard = UIStoryboard(name: "ContentFeed", bundle: NSBundle(forClass: ContentFeedViewControllerFactory.self))
        let contentFeedListVC = storyboard.instantiateViewControllerWithIdentifier("ContentFeedListViewController")
        
        return contentFeedListVC
    }
    
}
