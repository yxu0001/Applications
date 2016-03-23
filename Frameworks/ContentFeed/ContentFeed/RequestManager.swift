//
//  RequestManager.swift
//  ContentFeed
//
//  Copyright © 2016 athenahealth. All rights reserved.
//

import Foundation
import CoreData

/**
    A struct to set endpoint, (auth) path, and mdp path
*/
public struct Config {
    public var regproBaseURL = "www-dma.dev.epocrates.com"
    var regproEndpoint = "api"
    var regproPath = "/appsvr/login"
    var mdpPath = "/appsvr/secured/mdp/proxy"
    public var servicesBaseURL = "services-dma.dev.epocrates.com"
    
    // designated initializer. Scheme is part of the url!
    public init(regproBaseURL: String, regproEndpoint: String, regproPath: String, mdpPath: String, servicesBaseURL: String) {
        self.regproBaseURL = regproBaseURL
        self.regproEndpoint = regproEndpoint
        self.regproPath = regproPath
        self.mdpPath = mdpPath
        self.servicesBaseURL = servicesBaseURL
    }
    
    public init(regproBaseURL: String, servicesBaseURL: String) {
        self.init(regproBaseURL: regproBaseURL, regproEndpoint: "api", regproPath: "/appsvr/login", mdpPath: "/appsvr/secured/mdp/proxy", servicesBaseURL: servicesBaseURL)
    }
    
    public init() {
        self.init(regproBaseURL: "https://www-dma.dev.epocrates.com", regproEndpoint: "api", regproPath: "/appsvr/login",
            mdpPath: "/appsvr/secured/mdp/proxy", servicesBaseURL: "https://services-dma.dev.epocrates.com")
    }
}

public class RequestManager: NSObject {
    public var config: Config?
    public var token: String?
    
    lazy var defaultParameters = [String : String]()
    
    lazy var opQ: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "com.Epocrates.ContentFeed"
        return queue
    }()
    
    public func getContentFeedItems(count: Int, completion: ((success: Bool, data:[NSManagedObject]?, error: NSError?) -> Void)?) {
        guard let url = composeURL(action: "contentfeed", subaction: "dummy", moreParameters: nil) else {
            guard let completion = completion else { return }
            completion(success: false, data: nil, error: NSError(domain: "contentfeed.getcontentfeeditems", code: 1, userInfo: ["errmsg": "bad Url"]))
            return
        }
        
        let getContentFeedItemsOp = GetContentFeedItemsOp(withUrl: url)
        if let completion = completion {
            getContentFeedItemsOp.completionBlock = {
                completion(success: getContentFeedItemsOp.success, data: nil, error: getContentFeedItemsOp.error)
                print("getContentFeedItemsOp.completionBlock")
            }
        }
        self.opQ.addOperation(getContentFeedItemsOp)
    }
    
    internal func composeURL(action action: String, subaction: String?, moreParameters: [String: String]?) -> NSURL? {
        guard let config = config else { return nil }
        let urlString = config.regproBaseURL + "/" + config.regproPath
        /*
        var pairs = [String]()
        pairs.append("action=" + action)
        if let subaction = subaction {
            pairs.append("subaction=" + subaction)
        }
        pairs.append(convertParameterDictToQueryParameters(defaultParameters))
        if let moreParameters = moreParameters {
            pairs.append(convertParameterDictToQueryParameters(moreParameters))
        }
        
        let queryParameters = pairs.joinWithSeparator("&")
        guard let encodedQueryParameters = queryParameters.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            else {return nil}
        let finalUrlString = [urlString, encodedQueryParameters].joinWithSeparator("?")
        
        print(finalUrlString)
        guard let url = NSURL.init(string: finalUrlString) else {
            return nil
        }
        return url
        */
        print(urlString)
        return NSURL(string: urlString)
    }

    
    private func convertParameterDictToQueryParameters(paramDict: [String: String]) -> String {
        var queryParameters = ""
        var pairs = [String]()
        for key in paramDict.keys {
            guard let value = paramDict[key] else {continue}
            pairs.append(key + "=" + value)
        }
        
        if !pairs.isEmpty {
            queryParameters = pairs.joinWithSeparator("&")
        }
        return queryParameters
    }
}
