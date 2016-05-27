//
//  MapViewController.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 3/23/16.
//

import UIKit
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate {
    var selectedFeature: QuakeFeed.Feature!
    var feeds: [QuakeFeed.Feature]?

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedFeature != nil {
            let quakeLoc = CLLocation(latitude: selectedFeature.geometry.coordinates[1], longitude: selectedFeature.geometry.coordinates[0])
            updateMapView(quakeLoc)
//            let radius = exp(selectedFeature.properties.mag)*100
//            print("radius = \(radius)")
//            addCircle(quakeLoc, radius: radius as CLLocationDistance)
            addAnnotation(quakeLoc)
        }
        
        if let feeds = feeds where feeds.count > 0 {
            for feed in feeds {
                let quakeLoc = CLLocation(latitude: feed.geometry.coordinates[1], longitude: feed.geometry.coordinates[0])
//                updateMapView(quakeLoc)
                let radius = exp(feed.properties.mag/10.0)*10000.0
                print("radius = \(radius)")
                addCircle(quakeLoc, radius: radius as CLLocationDistance)
            }
        }
        
        mapView.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateMapView(location: CLLocation) {
        var region = MKCoordinateRegion()
        region.center.latitude = location.coordinate.latitude
        region.center.longitude = location.coordinate.longitude
        region.span.latitudeDelta = 10
        region.span.longitudeDelta = 10
        
        mapView.setRegion(region, animated: true)
    }
    
    private func addCircle(center: CLLocation, radius: Double) {
//        mapView.removeOverlays(mapView.overlays)
        let circle = MKCircle(centerCoordinate: center.coordinate, radius: radius)
        mapView.addOverlay(circle)
    }
    
    private func addAnnotation(center: CLLocation) {
//        let annotation = MKPointAnnotation()
//        annotation.title = "\(selectedFeature.properties.title)"
//        annotation.title = "latitude = \(selectedFeature.geometry.coordinates[1])," +
//                           "longitude = \(selectedFeature.geometry.coordinates[0])," +
//                           "depth = \(selectedFeature.geometry.coordinates[2])"
//        annotation.subtitle = "\(selectedFeature.properties.mag)"
//        annotation.coordinate = center.coordinate

        let annotation = CustomizedAnnotation()
        annotation.feature = selectedFeature
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        //if (annotation.isKindOfClass(MKPointAnnotation)) {
        if (annotation.isKindOfClass(CustomizedAnnotation)) {
            mapView.translatesAutoresizingMaskIntoConstraints = false
            //var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomAnnotation") as MKAnnotationView!
            //var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomAnnotation") as? MKPinAnnotationView
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomAnnotation") as?CustomizedAnnotationView

            
            if (annotationView == nil) {
                //annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
                //annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
                annotationView = CustomizedAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
                
//                let myView = UIView()
//                myView.backgroundColor = .greenColor()
//                
//                let widthConstraint = NSLayoutConstraint(item: myView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
//                myView.addConstraint(widthConstraint)
//                
//                let heightConstraint = NSLayoutConstraint(item: myView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20)
//                myView.addConstraint(heightConstraint)
//                
//                annotationView!.detailCalloutAccessoryView = myView
                annotationView!.canShowCallout = true
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKCircle) {
            let circleRender = MKCircleRenderer(overlay: overlay)
            circleRender.strokeColor = UIColor.redColor()
            circleRender.fillColor = UIColor.yellowColor()
            circleRender.lineWidth = 1
            circleRender.alpha = 0.5
            return circleRender
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    
}