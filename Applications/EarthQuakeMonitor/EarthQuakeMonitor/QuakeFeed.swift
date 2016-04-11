//
//  QuakeFeed.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 4/11/16.
//

import Foundation

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
