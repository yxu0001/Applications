//
//  MapCalloutView.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 4/15/16.
//

import UIKit

class MapCalloutView: UIView {

    @IBOutlet weak var label: UILabel!

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        UIColor.darkGray.setFill()
        
        // draw the pointed shape
        let pointShape = UIBezierPath()
        let middleX = self.frame.size.width/2.0
        pointShape.move(to: CGPoint(x: middleX - 10.0, y: self.frame.height - 10.0))
        pointShape.addLine(to: CGPoint(x: middleX, y: self.frame.height))
        pointShape.addLine(to: CGPoint(x: middleX + 10.0, y: self.frame.height - 10.0))
        pointShape.fill()
                
        // draw the rounded box
        let roundedRect = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height - 10.0), cornerRadius: 3.0)
        roundedRect.lineWidth = 2.0
        roundedRect.fill()
        
    }
    

}
