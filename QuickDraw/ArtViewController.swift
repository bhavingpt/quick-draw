//
//  ArtViewController.swift
//  QuickDraw
//
//  Created by Bhavin Gupta on 11/25/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

import UIKit

class ArtViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var endTurnButton: UIButton!
    @IBOutlet weak var trophyOne: UIButton!
    @IBOutlet weak var trophyTwo: UIButton!
    
    var last = CGPoint.zero
    var swiped = false
    let max_length: CGFloat = 300.0
    var remaining: CGFloat!
    
    var isDrawing = true
    var strokeWidth: CGFloat = 5.0
 
    var colorOne = UIColor(red: 0, green: 0.5, blue: 0.01, alpha: 1.0)
    var colorTwo = UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1.0)
    var colors: [UIColor]!
    var currentColor: UIColor!
    
    var turn: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        colors = [colorOne, colorTwo]
        endTurnButton.setTitleColor(colorOne, for: UIControlState.normal)
        currentColor = colors[turn]
        remaining = max_length
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            last = touch.location(in: self.view)
        }
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func drawLines(from: CGPoint, to: CGPoint) {
        let dist = distance(from, to)
        if remaining > dist {
            remaining = remaining - dist
            
            UIGraphicsBeginImageContext(self.view.frame.size)
            imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            let context = UIGraphicsGetCurrentContext()
            
            context?.move(to: CGPoint(x: from.x, y: from.y))
            context?.addLine(to: CGPoint(x: to.x, y: to.y))
            
            context?.setBlendMode(CGBlendMode.normal)
            context?.setLineCap(CGLineCap.round)
            context?.setLineWidth(strokeWidth)
            context?.setStrokeColor(currentColor.cgColor)
            
            context?.strokePath()
            
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        
        if let touch = touches.first {
            let current = touch.location(in: self.view)
            drawLines(from: last, to: current)
            last = current
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLines(from: last, to: last)
        }
    }

    @IBAction func reset(_ sender: UIButton) {
        self.imageView.image = nil
    }
    
    @IBAction func endTurn(_ sender: UIButton) {
        turn = 1 - turn
        currentColor = colors[turn]
        endTurnButton.setTitleColor(colors[turn], for: UIControlState.normal)
        endTurnButton.setTitle("End Player \(turn + 1)'s Turn", for: UIControlState.normal)
        
        remaining = max_length
    }
    
    // Useless things
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
