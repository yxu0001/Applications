//
//  QuakeFeedOp.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 3/21/16.
//

import NetworkConcurrentOp
import SwiftyJSON

enum AlertLevel: String {
    case green, yellow, orange, red
}

struct QuakeFeedKey {
    let type = "type"
    
    // metadata
    let metadata = "metadata"
    let metatdataKey = MetadataKey()
    
    // features
    let features = "features"
    let featureKey = FeatureKey()
    
    // bbox
    let bbox = "bbox"
    
    
    struct MetadataKey {
        let generated = " generated"
        let url = "url"
        let title = "title"
        let status = "status"
        let api = "api"
        let count = "count"
    }
    
    
    struct FeatureKey {
        let type = "type"
        let properties = "properties"
        let propertyKey = PropertyKey()
        let geometry = "geometry"
        let geometryKey = GeometryKey()
        let id = "id"
        
        
        struct PropertyKey {
            let mag = "mag"
            let place = "place"
            let time = "time"
            let updated = "updated"
            let tz = "tz"
            let url = "url"
            let detail = "detail"
            let felt = "felt"
            let cdi = "cdi"
            let mmi = "mmi"
            let alert = "alert"
            let status = "status"
            let tsunami = "tsunami"
            let sig = "sig"
            let net = "net"
            let code = "code"
            let ids = "ids"
            let sources = "sources"
            let types = "types"
            let nst = "nst"
            let dmin = "dmin"
            let rms = "rms"
            let gap = "gap"
            let magType = "magType"
            let type = "type"
            let title = "title"
        }
        
        struct GeometryKey {
            let type = "type"
            let coordinates = "coordinates"
        }
    }
}

// Objects
struct QuakeFeed {
    var type: String!
    var metadata: Metadata!
    var features: [Feature]!
    var bbox: [Double]!
    
    struct Metadata {
        var generated: NSTimeInterval!
        var url: String!
        var title: String!
        var status: Int!
        var api: String!
        var count: Int!
    }
    
    struct Feature {
        var type: String!
        var properties: Property!
        var geometry: Geometry!
        var id: String!
        
        struct Property {
            var mag: Double!
            var place: String!
            var time: NSTimeInterval!
            var updated: NSTimeInterval!
            var tz: Int!
            var url: String?
            var detail: String?
            var felt: Int?
            var cdi: Double?
            var mmi: Double?
            //var alert: String!
            var alert: AlertLevel?
            var status: String!
            var tsunami: Int!
            var sig: Int!
            var net: String?
            var code: String!
            var ids: String?
            var sources: String?
            var types: String?
            var nst: Int!
            var dmin: Double!
            var rms: Double!
            var gap: Int!
            var magType: String!
            var type: String!
            var title: String!
        }
        
        struct Geometry {
            var type: String!
            var coordinates: [Double]! // longitude, latitude, depth
        }
    }
}

class QuakeFeedOp: NetworkConcurrentOperation {
    
    var success = false
    var feed: QuakeFeed?
    var error: NSError?
    
    override func parse(data: NSData) {
        let json = JSON(data: data)
        
        let keys = QuakeFeedKey()
        feed = QuakeFeed()
        
        
        feed?.type = json[keys.type].stringValue
        let metadata = json[keys.metadata]
        var meta = QuakeFeed.Metadata()
        meta.generated = NSTimeInterval(metadata[keys.metatdataKey.generated].int64Value)
        meta.url = metadata[keys.metatdataKey.url].stringValue
        meta.title = metadata[keys.metatdataKey.title].stringValue
        meta.status = metadata[keys.metatdataKey.status].intValue
        meta.api = metadata[keys.metatdataKey.api].stringValue
        meta.count = metadata[keys.metatdataKey.count].intValue
        feed?.metadata = meta
        
        let bboxData = json[keys.bbox]
        var bbox = [Double]()
        for b in bboxData.arrayValue {
            bbox.append(b.doubleValue)
        }
        feed?.bbox = bbox
        
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
        feed?.features = featuresArr
        success = true
    }
    
}
