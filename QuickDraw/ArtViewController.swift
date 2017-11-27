//
//  ArtViewController.swift
//  QuickDraw
//
//  Created by Bhavin Gupta on 11/25/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

import UIKit
import AudioToolbox

class ArtViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var endTurnButton: UIButton!
    @IBOutlet weak var trophyOne: UIButton!
    @IBOutlet weak var trophyTwo: UIButton!
    @IBOutlet weak var toolButton: UIButton!
    @IBOutlet weak var inkLabel: UILabel!
    @IBOutlet weak var clock: UILabel!
    @IBOutlet weak var target: UILabel!
    
    // MARK: Customizable presettings
    let max_length: CGFloat = 250.0
    let erase_penalty: CGFloat = 1.5
    let strokeWidth: CGFloat = 5.0
    let eraseWidth: CGFloat = 15.0
    let countdown: String = "5.0"
    
    var timer = Timer()
    var startedTimer: Bool = false
    
    var storedImage: UIImage?
    var displayingWin: Bool = false
    let wins: [UIImage] = [#imageLiteral(resourceName: "winOne"), #imageLiteral(resourceName: "winTwo")]
    let trophyPics: [UIImage] = [#imageLiteral(resourceName: "trophy"), #imageLiteral(resourceName: "trophy2")]
    var trophies: [UIButton]?
    
    var last = CGPoint.zero
    var swiped = false
    var remaining: CGFloat!
    
    var isDrawing = true
    
    var colorOne = UIColor(red: 0, green: 0.5, blue: 0.01, alpha: 1.0)
    var colorTwo = UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1.0)
    var colors: [UIColor]!
    var currentColor: UIColor!
    @IBOutlet weak var progress: UIProgressView!
    
    var turn: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = nil
        target.isHidden = true
        
        trophies = [trophyOne, trophyTwo]
        colors = [colorOne, colorTwo]
        turn = 0
        resetTimer()
        
        changeColor()
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
        var dist = distance(from, to)
        if !isDrawing {
            dist *= erase_penalty
        }
        
        if remaining > dist {
            if (dist == 0) {
                remaining = remaining - 1
            } else {
                remaining = remaining - dist
            }
            
            progress.setProgress(Float(max_length - remaining) / Float(max_length), animated: true)
            
            UIGraphicsBeginImageContext(self.view.frame.size)
            imageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            let context = UIGraphicsGetCurrentContext()
            
            context?.move(to: CGPoint(x: from.x, y: from.y))
            context?.addLine(to: CGPoint(x: to.x, y: to.y))
            
            context?.setBlendMode(CGBlendMode.normal)
            context?.setLineCap(CGLineCap.round)
            
            if isDrawing {
                context?.setLineWidth(strokeWidth)
                context?.setStrokeColor(currentColor.cgColor)
            } else {
                context?.setLineWidth(eraseWidth)
                context?.setStrokeColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor)
            }
            
            context?.strokePath()
            
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        if (remaining < 10 && !startedTimer) {
            startedTimer = true
            clock.isHidden = false
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
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
            if (remaining > 5){
                drawLines(from: last, to: last)
            }
        }
    }

    @IBAction func reset(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Would you like to restart?", message: "This will be a loss for player \(turn + 1)!", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "New game", style: .default, handler: { (_) in
            self.viewDidLoad()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func switchTool(_ sender: UIButton) {
        isDrawing = !isDrawing
        if (isDrawing) {
            toolButton.setImage(#imageLiteral(resourceName: "EraserIcon"), for: UIControlState.normal)
        } else {
            toolButton.setImage(#imageLiteral(resourceName: "paintBrush"), for: UIControlState.normal)
        }
    }
    
    @IBAction func endTurn(_ sender: UIButton) {
        trophyUp(trophies![turn])
        
        turn = 1 - turn
        changeColor()
        resetTimer()
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        endTurnButton.setTitle("End Player \(turn + 1)'s Turn", for: UIControlState.normal)
        toolButton.setImage(#imageLiteral(resourceName: "EraserIcon"), for: UIControlState.normal)
        isDrawing = true
        
        remaining = max_length
    }
    
    func changeColor() {
        trophies![turn].setImage(trophyPics[turn], for: UIControlState.normal)
        trophies![turn].isEnabled = true
        trophies![1 - turn].setImage(#imageLiteral(resourceName: "boring"), for: UIControlState.normal)
        trophies![1 - turn].isEnabled = false
        
        
        currentColor = colors[turn]
        endTurnButton.setTitleColor(currentColor, for: UIControlState.normal)
        inkLabel.textColor = currentColor
        progress.progressTintColor = currentColor
        progress.setProgress(0.0, animated: false)
    }
    
    func resetTimer() {
        timer.invalidate()
        clock.text = countdown
        clock.isHidden = true
        startedTimer = false
    }
    
    @objc func updateTimer() {
        let arr = clock.text!.components(separatedBy: ".")
        let time = Int(arr[0])! * 10 + Int(arr[1])!
        
        if (time == 0) {
            endTurn(endTurnButton)
        } else {
            let newTime = time - 1
            clock.text = String(newTime / 10) + "." + String(newTime % 10)
        }
    }
    
    @IBAction func trophyDown(_ sender: UIButton) {
        if (turn == sender.tag) {
            target.isHidden = false
            target.text = "Player \(turn + 1) Target"
            displayingWin = true
            storedImage = self.imageView.image
            self.imageView.image = wins[turn]
        }
    }
    
    @IBAction func trophyUp(_ sender: UIButton) {
        if (displayingWin) {
            target.isHidden = true
            self.imageView.image = storedImage
            displayingWin = false
        }
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
