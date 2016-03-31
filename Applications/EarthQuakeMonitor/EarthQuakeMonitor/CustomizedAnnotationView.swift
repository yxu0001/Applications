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
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = "Test"
        self.backgroundColor = UIColor.clearColor()
        self.addSubview(label)
        self.centerOffset = CGPoint(x: 0.0, y: -50.0)
        self.alpha = 0.6
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size = CGSize(width: 100, height: 100)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(annotation: nil, reuseIdentifier: nil)
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        UIColor.darkGrayColor().setFill()
        
        // draw the pointed shape
        let pointShape = UIBezierPath()
        pointShape.moveToPoint(CGPoint(x: 40.0, y: 90.0))
        pointShape.addLineToPoint(CGPoint(x: 50.0, y: 100.0))
        pointShape.addLineToPoint(CGPoint(x: 60, y: 90.0))
        pointShape.fill()
        
//        // draw the rounded box
//        let roundedRect = UIBezierPath(roundedRect: CGRect(x: kRoundBoxLeft, y: 0.0, width: self.frame.size.width - kRoundBoxLeft, height: self.frame.size.height), cornerRadius: 3.0)
//        roundedRect.lineWidth = 2.0
//        roundedRect.fill()
        
        let roundedRect = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height - 10.0), cornerRadius: 3.0)
        roundedRect.lineWidth = 2.0
        roundedRect.fill()

    }

}
