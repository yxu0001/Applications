//
//  CustomizedAnnotationView.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 3/30/16.
//

import UIKit
import MapKit

class CustomizedAnnotationView: MKAnnotationView {
    let kRoundBoxLeft: CGFloat = 10.0
    var calloutView: UIView?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        if let annotation = annotation as? CustomizedAnnotation,
            calloutView = NSBundle.mainBundle().loadNibNamed("MapCalloutView", owner: self, options: nil).first as? MapCalloutView {
            let text = annotation.textForLabel ?? ""
            calloutView.label.text = text
            var calloutViewFrame = calloutView.frame
            calloutViewFrame.origin.x = -(calloutViewFrame.width - self.bounds.width) * 0.5
            calloutViewFrame.origin.y = -calloutViewFrame.height
            calloutView.frame = calloutViewFrame
            self.addSubview(calloutView)
            
            setNeedsLayout()
        }
        self.backgroundColor = UIColor.clearColor()
        self.alpha = 0.6
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.frame.size = CGSize(width: 100, height: 100)
        self.frame.size = CGSizeZero
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(annotation: nil, reuseIdentifier: nil)
    }
}
