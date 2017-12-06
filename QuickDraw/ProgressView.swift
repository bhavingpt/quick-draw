//
//  ProgressView.swift
//  QuickDraw
//
//  Created by Bhavin Gupta on 12/6/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    var wipe = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        wipe = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.addRect(rect)
        
        var use = rect
        if (rect.width >= self.bounds.width * 0.90) {
            use = self.bounds
        }
        
        let fill: UIColor = UIColor(red: CGFloat(0.3789), green: CGFloat(0.4727), blue: CGFloat(0.996), alpha: 1)
        ctx.setFillColor(wipe ? UIColor.white.cgColor : fill.cgColor)
        ctx.fill(use)
        
        let darkBlue = UIColor(red: CGFloat(0.2109), green: CGFloat(0.2852), blue: CGFloat(0.6992), alpha: 1)
        
        wipe = false
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: self.bounds.height))
        path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        path.lineWidth = 3
        darkBlue.setStroke()
        
        path.stroke()
    }

}
