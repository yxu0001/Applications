//
//  AppDelegate.swift
//  NewsFeedTestHarness
//
//  Created by Yijia Xu on 3/8/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit
import ContentFeed

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
//        let bundle = NSBundle(forClass: NewsFeedListViewController.self)
//        let storyboard = UIStoryboard(name: "NewsFeed", bundle: bundle)
//        let listNavVC = storyboard.instantiateInitialViewController()
        
        let listNavVC = ContentFeedViewControllerFactory.contentFeedNavViewController()
        UINavigationBar.appearance().barTintColor = UIColor(red:CGFloat(0x59/255.0), green:CGFloat(0x2c/255.0), blue:CGFloat(0x81/255.0), alpha:CGFloat(1.0))
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        let fistTabBarItem = UITabBarItem(title: "Test1", image: nil, selectedImage: nil)
        listNavVC?.tabBarItem = fistTabBarItem
        
        let second = SecondViewController()
        let nav2 = UINavigationController()
        nav2.viewControllers = [second]
        let secondTabBarItem = UITabBarItem(title: "Test2", image: nil, selectedImage: nil)
        nav2.tabBarItem = secondTabBarItem
        
        let tabs = UITabBarController()
        tabs.viewControllers = [listNavVC!, nav2]
        
        self.window?.rootViewController = tabs
        self.window?.makeKeyAndVisible()
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

