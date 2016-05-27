//
//  AFRequestManager.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 4/11/16.
//

import Alamofire
import SwiftyJSON

class AFRequestManager: NSObject {
    
    lazy var config = Config()
    let queue = dispatch_queue_create("com.earthquakemonitor.queue", DISPATCH_QUEUE_CONCURRENT)
    
//    private func composeURL(path: String, resource: String) -> NSURL? {
//        let urlString = config.scheme + "://" + config.host + "/" + config.endpoint + "/" + path + "/" + resource
//        
//        return NSURL(string: urlString)
//    }
    
    private func urlString(path: String, resource: String) -> String {
        return config.scheme + "://" + config.host + "/" + config.endpoint + "/" + path + "/" + resource
    }

    func fetchQuakeSummary(feedSummaryTimeInterval: FeedSummaryTimeInterval, completion: ((success: Bool, feed: QuakeFeed?, error: NSError?) -> Void)?) {
        Alamofire.request(.GET, urlString("summary", resource: feedSummaryTimeInterval.rawValue), parameters: nil, encoding: .URL, headers: nil)
            .responseJSON(queue: queue, options: .AllowFragments, completionHandler: {
                response in
                guard response.result.isSuccess else {
                    print("Error while fetching tags: \(response.result.error)")
                    guard let completion = completion else { return }
                    completion(success: false, feed: nil, error: response.result.error!)
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: AnyObject] else {
                    print("Invalid tag information received from service")
                    guard let completion = completion else { return }
                    completion(success: false, feed: nil, error: response.result.error!)
                    return
                }
                let feed = self.parseSummary(responseJSON)
                guard let completion = completion else { return }
                completion(success: true, feed: feed, error: nil)
        })
    }

    private func parseSummary(summaryJSON: [String: AnyObject]) -> QuakeFeed? {
        let keys = QuakeFeedKey()
        var feed = QuakeFeed()
        
        let json = JSON(summaryJSON)
        
        feed.type = json[keys.type].stringValue
        let metadata = json[keys.metadata]
        var meta = QuakeFeed.Metadata()
        meta.generated = NSTimeInterval(metadata[keys.metatdataKey.generated].int64Value)
        meta.url = metadata[keys.metatdataKey.url].stringValue
        meta.title = metadata[keys.metatdataKey.title].stringValue
        meta.status = metadata[keys.metatdataKey.status].intValue
        meta.api = metadata[keys.metatdataKey.api].stringValue
        meta.count = metadata[keys.metatdataKey.count].intValue
        feed.metadata = meta
        
        let bboxData = json[keys.bbox]
        var bbox = [Double]()
        for b in bboxData.arrayValue {
            bbox.append(b.doubleValue)
        }
        feed.bbox = bbox
        
        let features = json[keys.features].arrayValue
        var featuresArr = Array<QuakeFeed.Feature>()
        for f in features {
            var feature = QuakeFeed.Feature()
            feature.id = f[keys.featureKey.id].stringValue
            feature.type = f[keys.featureKey.type].stringValue
            var geometry = QuakeFeed.Feature.Geometry()
            let geometryJSON = f[keys.featureKey.geometry]
            geometry.type = geometryJSON[keys.featureKey.geometryKey.type].stringValue
            var coordinates = [Double]()
            for c in geometryJSON[keys.featureKey.geometryKey.coordinates].arrayValue {
                coordinates.append(c.doubleValue)
            }
            geometry.coordinates = coordinates
            feature.geometry = geometry
            var property = QuakeFeed.Feature.Property()
            let propertyJSON = f[keys.featureKey.properties]
            property.mag = propertyJSON[keys.featureKey.propertyKey.mag].doubleValue
            property.place = propertyJSON[keys.featureKey.propertyKey.place].stringValue
            property.time = NSTimeInterval(integerLiteral: propertyJSON[keys.featureKey.propertyKey.time].int64Value)
            property.updated = NSTimeInterval(integerLiteral: propertyJSON[keys.featureKey.propertyKey.updated].int64Value)
            property.tz = propertyJSON[keys.featureKey.propertyKey.tz].intValue
            property.url = propertyJSON[keys.featureKey.propertyKey.url].string
            property.detail = propertyJSON[keys.featureKey.propertyKey.detail].string
            property.felt = propertyJSON[keys.featureKey.propertyKey.felt].int
            property.cdi = propertyJSON[keys.featureKey.propertyKey.cdi].double
            property.mmi = propertyJSON[keys.featureKey.propertyKey.mmi].double
            if let alert = AlertLevel(rawValue: propertyJSON[keys.featureKey.propertyKey.alert].stringValue) {
                property.alert = alert
            }
            //property.alert = propertyJSON[keys.featureKey.propertyKey.alert].stringValue
            property.status = propertyJSON[keys.featureKey.propertyKey.status].stringValue
            property.tsunami = propertyJSON[keys.featureKey.propertyKey.tsunami].intValue
            property.sig = propertyJSON[keys.featureKey.propertyKey.sig].intValue
            property.net = propertyJSON[keys.featureKey.propertyKey.net].string
            property.code = propertyJSON[keys.featureKey.propertyKey.code].stringValue
            property.ids = propertyJSON[keys.featureKey.propertyKey.ids].string
            property.sources = propertyJSON[keys.featureKey.propertyKey.sources].string
            property.types = propertyJSON[keys.featureKey.propertyKey.types].string
            property.nst = propertyJSON[keys.featureKey.propertyKey.nst].intValue
            property.dmin = propertyJSON[keys.featureKey.propertyKey.dmin].doubleValue
            property.rms = propertyJSON[keys.featureKey.propertyKey.rms].doubleValue
            property.gap = propertyJSON[keys.featureKey.propertyKey.gap].intValue
            property.magType = propertyJSON[keys.featureKey.propertyKey.magType].stringValue
            property.type = propertyJSON[keys.featureKey.propertyKey.type].stringValue
            property.title = propertyJSON[keys.featureKey.propertyKey.title].stringValue
            feature.properties = property
            
            featuresArr.append(feature)
        }
        feed.features = featuresArr
        
        return feed
    }
    
}
