//
//  GetContentFeedItemsOp.swift
//  ContentFeed
//
//  Copyright © 2016 athenahealth. All rights reserved.
//

import SwiftyJSON
import CoreData

struct ContentFeedItemKey {
    let id = "id"
    let diseases = "diseases"
    let rating = "rating"
    let version = "version"
    let relatedArticles = "relatedArticles"
    let sourceImageURL = "sourceImageURL"
    let timestamp = "timestamp"
    let authors = "authors"
    let drugs = "drugs"
    let marqueeImageURL = "marqueeImageURL"
    let source = "source"
    let type = "type"
    let geocoding = "geocoding"
    let country = "country"
    let region = "region"
    let city = "city"
    let location = "location"
    let summary = "summary"
    let scoring = "scoring"
    let bodyURL = "bodyURL"
    let name = "name"
}

class GetContentFeedItemsOp: NetworkConcurrentOperation {
    var success: Bool = false
    var data: [NSManagedObject]?

    override func parse(data: NSData) {
        let json = JSON(data:data)
        print(json)
        
        if let dict = json.dictionary,
            dataDict = dict["data"] {
                let errorcode = dataDict["errcode"].stringValue
                if errorcode == "0" {
                    self.success = true
                    if let occupationsArr = dataDict["occupations"].array {
                    }
                } else {
                    self.success = false
                    createError(dataDict, errorcode: Int(errorcode))
                }
        } else {
            self.success = false
            createError(nil, errorcode: nil)
        }
    }

    
}
