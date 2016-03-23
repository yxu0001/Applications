//
//  NetworkConcurrentOperation.swift
//
//  Copyright © 2016 athenahealth. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias RequestCompletionHandler = (NSData?, NSURLResponse?, NSError?) -> Void

/// keys for the error dictionary in the response
struct ErrorKey {
    let errcode = "errcode"
    let errmsg = "errmsg"
}

/// enum of HTTP methods
public enum HTTPMethod: String {
    case GET = "GET"
    case PUT = "PUT"
    case POST = "POST"
    case DELETE = "DELETE"
}

/// Parent class for NSURLSessionTask operations -- to reduce duplicated code
class NetworkConcurrentOperation: ConcurrentOperation {
    internal var url: NSURL
    var task: NSURLSessionTask?
    var error: NSError?
    internal let errorKeys = ErrorKey()
    internal var errorDomain = "NetworkConcurrentOperation"
    internal let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    internal var httpMethod = HTTPMethod.GET // default
    internal var postData: NSData?
    internal var httpHeaders: NSDictionary?
    
    init(withUrl url: NSURL, httpMethod: HTTPMethod, postData: NSData?, httpHeaders: NSDictionary?) {
        self.url = url
        self.postData = postData
        self.httpMethod = httpMethod
        self.httpHeaders = httpHeaders
        super.init()
    }

    convenience init(withUrl url: NSURL) {
        self.init(withUrl: url, httpMethod: .GET, postData: nil, httpHeaders: nil)
    }
        
    override func start() {
        super.start()
        
        if cancelled {
            return
        }
        
        
        if httpMethod == .GET {
            task = getNSURLSessionTask(url, completion: {
                [weak self](data: NSData?, response: NSURLResponse?, error: NSError?) in
                guard let weakself = self else {
                    assert(self == nil, "self is nil")
                    return
                }
                if !weakself.cancelled {
                    if let error = error {
                        weakself.error = error
                    } else {
                        if let data = data {
                            weakself.parse(data)
                        } else {
                            print("data is nil")
                            weakself.error = NSError(domain: weakself.errorDomain, code: 2, userInfo: [weakself.errorKeys.errmsg: "data is nil"])
                        }
                    }
                } else {
                    if let error = error {
                        weakself.error = error
                    } else {
                        print("request cancelled")
                        weakself.error = NSError(domain: weakself.errorDomain, code: 3, userInfo: [weakself.errorKeys.errmsg: "request cancelled"])
                    }
                }
                
                weakself.finished = true
                weakself.executing = true
                })
        }
        
        if httpMethod == .POST {
            task = postNSURLSessionTask(url, rdp: true, postData: postData, completion: {
                [weak self](data: NSData?, response: NSURLResponse?, error: NSError?) in
                guard let weakself = self else { return }
                if !weakself.cancelled {
                    if let error = error {
                        weakself.error = error
                    } else {
                        if let data = data {
                            weakself.parse(data)
                        } else {
                            print("data is nil")
                            weakself.error = NSError(domain: weakself.errorDomain, code: 2, userInfo: [weakself.errorKeys.errmsg: "data is nil"])
                        }
                    }
                } else {
                    if let error = error {
                        weakself.error = error
                    } else {
                        print("request cancelled")
                        weakself.error = NSError(domain: weakself.errorDomain, code: 3, userInfo: [weakself.errorKeys.errmsg: "request cancelled"])
                    }
                }
                
                weakself.finished = true
                weakself.executing = true
                })
        }
        
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
    /**
     - parameter url: composed url
     - parameter completion: completion handler, perform parsing or error handling
     - returns: NSURLSessionTask (get task)
     */
    private func getNSURLSessionTask(url: NSURL, completion: RequestCompletionHandler) -> NSURLSessionTask {
        let request = NSMutableURLRequest.init(URL: url)
        request.HTTPMethod = HTTPMethod.GET.rawValue
        return session.dataTaskWithRequest(request, completionHandler: completion)
    }
    
    /**
     - parameter url: composed url
     - parameter rdp: boolean required for CDS post requests
     - parameter postData: NSData? UTF8 encoded post data
     - parameter completion: completion handler, perform parsing or error handling
     - returns: NSURLSessionTask (upload task)
     */
    private func postNSURLSessionTask(url: NSURL, rdp: Bool, postData: NSData?, completion: RequestCompletionHandler) -> NSURLSessionTask {
        let request = NSMutableURLRequest.init(URL: url)
        request.HTTPMethod = HTTPMethod.POST.rawValue
        if let httpHeaders = httpHeaders {
            for set in httpHeaders {
                if let value = set.value as? String, let key = set.key as? String {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
        }
        return session.uploadTaskWithRequest(request, fromData: postData, completionHandler: completion)
    }
    
    internal func parse(data: NSData) {
        // override point
    }
    
    internal func createError(dataDict: JSON?, errorcode: Int?) {
        guard let dataDict = dataDict else {
            error = NSError(domain: errorDomain, code: errorcode ?? 2, userInfo: [errorKeys.errmsg: "data is nil"])
            return
        }
        if let errors = dataDict["errors"].array where errors.count > 0 {
            error = NSError(domain: self.errorDomain, code: errorcode ?? 1, userInfo: [errorKeys.errmsg: errors[0][errorKeys.errmsg].stringValue,
                errorKeys.errcode: errors[0][errorKeys.errcode].stringValue])
        } else {
            error = NSError(domain: self.errorDomain, code: errorcode ?? 1, userInfo: [errorKeys.errmsg: dataDict[errorKeys.errmsg].stringValue])
        }
    }


}
