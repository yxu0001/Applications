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
            addCircle(quakeLoc, radius: 10000.0 as CLLocationDistance)
            addAnnotation(quakeLoc)
        }
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
        mapView.removeOverlays(mapView.overlays)
        let circle = MKCircle(centerCoordinate: center.coordinate, radius: radius)        
        mapView.addOverlay(circle)
    }
    
    private func addAnnotation(center: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.title = "latitude = \(selectedFeature.geometry.coordinates[1])," +
                           "longitude = \(selectedFeature.geometry.coordinates[0])," +
                           "depth = \(selectedFeature.geometry.coordinates[2])"
        annotation.subtitle = "\(selectedFeature.properties.mag)"
        annotation.coordinate = center.coordinate
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
        
        if (annotation.isKindOfClass(MKPointAnnotation)) {
            mapView.translatesAutoresizingMaskIntoConstraints = false
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomAnnotation") as MKAnnotationView!
            
            if (annotationView == nil) {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
                annotationView.canShowCallout = true
            } else {
                annotationView.annotation = annotation;
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
            return circleRender
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    
}