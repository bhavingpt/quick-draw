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
        
        let light_purple = UIColor.init(red: CGFloat(50)/255, green: CGFloat(162)/255, blue: CGFloat(208)/255, alpha: 1.0)
        let fill: UIColor = light_purple
        ctx.setFillColor(wipe ? UIColor.white.cgColor : fill.cgColor)
        ctx.fill(rect)
        
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
