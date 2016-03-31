//
//  CustomizedAnnotation.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 3/30/16.
//

import UIKit
import MapKit

class CustomizedAnnotation: NSObject, MKAnnotation {
    var feature: QuakeFeed.Feature!
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: feature.geometry.coordinates[1], longitude: feature.geometry.coordinates[0])
    }
    
    var title: String? {
        return nil
    }

}
