//
//  RequestManager.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 3/21/16.
//

import Foundation

struct Config {
    var scheme = "http"
    var host = "earthquake.usgs.gov"
    var endpoint = "earthquakes/feed/v1.0"
}

enum FeedSummaryTimeInterval: String {
    case Hour = "significant_hour.geojson"
    case Day = "significant_day.geojson"
    case Week = "significant_week.geojson"
    case Month = "significant_month.geojson"
    case AllDay = "all_day.geojson"
    case AllWeek = "all_week.geojson"
    case AllMonth = "all_month.geojson"
    case FourPointFiveDay = "4.5_day.geojson"
    case FourPointFiveWeek = "4.5_week.geojson"
    case FourPointFiveMonth = "4.5_month.geojson"
}

typealias RequestCompletionHandler = (NSData?, NSURLResponse?, NSError?) -> Void

class RequestManager: NSObject {
    
    lazy var config = Config()
    
    lazy var opQ: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "EarthQuakeMonitor.request"
        return queue
    }()

    
    private func composeURL(path: String, resource: String) -> NSURL? {
        let urlString = config.scheme + "://" + config.host + "/" + config.endpoint + "/" + path + "/" + resource
        
        return NSURL(string: urlString)
    }
    
    func fetchQuakeSummary(feedSummaryTimeInterval: FeedSummaryTimeInterval, completion: ((success: Bool, feed: QuakeFeed?, error: NSError?) -> Void)?) {
        guard let url = composeURL("summary", resource: feedSummaryTimeInterval.rawValue) else {
            print("url is nil")
            
            guard let completion = completion else { return }
            completion(success: false, feed: nil, error: NSError(domain: "fetchQuakeSummary", code: 3, userInfo: ["errmsg": "Bad url"]))
            return
        }
        
        let quakeFeedOp = QuakeFeedOp(withUrl: url)
        if let completion = completion {
            quakeFeedOp.completionBlock = {
                completion(success: quakeFeedOp.success, feed: quakeFeedOp.feed, error: quakeFeedOp.error)
            }
        }
        self.opQ.addOperation(quakeFeedOp)
    }
    
}
