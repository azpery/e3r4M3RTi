//
//  DrawingView.swift
//  OremiaMobile2
//
//  Created by Zumatec on 15/05/2016.
//  Copyright © 2016 Zumatec. All rights reserved.
//

import UIKit

class DrawableView: UIView {
    
    let path=UIBezierPath()
    var previousPoint:CGPoint
    var lineWidth:CGFloat=0.0
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override init(frame: CGRect) {
        previousPoint=CGPoint.zero
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        previousPoint=CGPoint.zero
        super.init(coder: aDecoder)!
        var panGestureRecognizer=UIPanGestureRecognizer(target: self, action: "pan:")
        panGestureRecognizer.maximumNumberOfTouches=1
        self.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        UIColor.greenColor().setStroke()
        path.stroke()
        path.lineWidth=lineWidth
    }
    func pan(panGestureRecognizer:UIPanGestureRecognizer)->Void
    {
        var currentPoint=panGestureRecognizer.locationInView(self)
        let midPoint=self.midPoint(previousPoint, p1: currentPoint)
        
        if panGestureRecognizer.state == .Began
        {
            path.moveToPoint(currentPoint)
        }
        else if panGestureRecognizer.state == .Changed
        {
            path.addQuadCurveToPoint(midPoint,controlPoint: previousPoint)
        }
        
        previousPoint=currentPoint
        self.setNeedsDisplay()
    }
    func midPoint(p0:CGPoint,p1:CGPoint)->CGPoint
    {
        let x=(p0.x+p1.x)/2
        let y=(p0.y+p1.y)/2
        return CGPoint(x: x, y: y)
    }
    
}
