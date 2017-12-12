//
//  ArtViewController.swift
//  QuickDraw
//
//  Created by Bhavin Gupta on 11/25/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class ArtViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var endTurnButton: UIButton!
    @IBOutlet weak var toolButton: UIButton!
    @IBOutlet weak var delay: UIActivityIndicatorView!
    @IBOutlet weak var trophy: UIButton!
    @IBOutlet weak var divider: UIImageView!
    
    // MARK: Customizable presettings
    let max_length: CGFloat = 250.0
    let erase_penalty: CGFloat = 1.5
    let strokeWidth: CGFloat = 4.5
    let eraseWidth: CGFloat = 9.0
    
    let countdown: String = "2.0"
    var clock: String?
    
    var timer = Timer()
    var visionTimer = Timer()
    var startedTimer: Bool = false
    var timeEffect: AVAudioPlayer?
    
    var storedImage: UIImage?
    var displayingWin: Bool = false
    let wins: [UIImage] = [#imageLiteral(resourceName: "winOne"), #imageLiteral(resourceName: "winTwo")]
    let trophyPics: [UIImage] = [#imageLiteral(resourceName: "trophy"), #imageLiteral(resourceName: "trophy2")]
    
    let cv2 = OpenCVWrapper()
    
    var score: [Int] = [0, 0]
    @IBOutlet weak var scoreOne: UILabel!
    @IBOutlet weak var scoreTwo: UILabel!
    
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var playerOneName: UILabel!
    @IBOutlet weak var playerTwoName: UILabel!
    
    var last = CGPoint.zero
    var swiped = false
    var remaining: CGFloat!
    
    var isDrawing = true
    
    var colorOne = UIColor(red: 0, green: 0.5, blue: 0.01, alpha: 1.0)
    var colorTwo = UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1.0)
    var colors: [UIColor]!
    var currentColor: UIColor!
    @IBOutlet weak var progress: ProgressView!
    
    var turn: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: "clockticking", ofType: "wav")!)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! timeEffect = AVAudioPlayer(contentsOf: alertSound)
        timeEffect?.numberOfLoops = -1
    
        print (cv2.openCVVersionString())
        
        self.imageView.image = #imageLiteral(resourceName: "empty")
        delay.isHidden = true
        divider.isHidden = false
        delay.stopAnimating()
        scoreOne.isHidden = false
        scoreTwo.isHidden = false
        scoreOne.text = "0"
        scoreTwo.text = "0"
        
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
            
            let percent = Float(max_length - remaining) / Float(max_length)
            
            if (percent < 0.95) {
                progress.setNeedsDisplay(CGRect(x: 0.0, y: 0.0, width: CGFloat(percent) * progress.bounds.width, height: progress.bounds.width))
            } else {
                progress.setNeedsDisplay()
            }
            
            let pic = imageView.image!
            let originX = imageView.frame.origin.x
            let originY = imageView.frame.origin.y
            
            UIGraphicsBeginImageContext(pic.size)
            
            pic.draw(at: CGPoint.zero)
            let context = UIGraphicsGetCurrentContext()
            
            let fromPointX = (from.x - originX) / imageView.frame.size.width
            let fromPointY = (from.y - originY) / imageView.frame.size.height
            let toPointX = (to.x - originX) / imageView.frame.size.width
            let toPointY = (to.y - originY) / imageView.frame.size.height

            context?.move(to: CGPoint(x: fromPointX * pic.size.width, y: fromPointY * pic.size.height))
            context?.addLine(to: CGPoint(x: toPointX * pic.size.width, y: toPointY * pic.size.height))
            
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
        
        if (remaining <= (0.05 * max_length) && !startedTimer && !delay.isAnimating) {
            startedTimer = true
            timeEffect?.play()
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
        let players = [playerOneName, playerTwoName]
        let def_string = turn == 0 ? "player one" : "player two"
        let actionSheet = UIAlertController(title: "Would you really like to restart?", message: "This will be a loss for \(players[turn]?.text ?? def_string)!", preferredStyle: .actionSheet)
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
        resetTimer()
        scoreOne.isHidden = true
        scoreTwo.isHidden = true
        delay.isHidden = false
        divider.isHidden = true
        delay.startAnimating()
        
        visionTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(updateScores), userInfo: nil, repeats: false)
        
        trophyUp(trophy)
        
        turn = 1 - turn
        changeColor()
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        toolButton.setImage(#imageLiteral(resourceName: "EraserIcon"), for: UIControlState.normal)
        isDrawing = true
        
        remaining = max_length
        
        score = similarity(input: self.imageView.image!)
    }
    
    @objc func updateScores() {
        visionTimer.invalidate()
        
        delay.isHidden = true
        divider.isHidden = false
        delay.stopAnimating()
        
        scoreOne.text = "\(score[0])"
        scoreTwo.text = "\(score[1])"
        
        scoreOne.isHidden = false
        scoreTwo.isHidden = false
    }
    
    func changeColor() {
        trophy.setImage(trophyPics[turn], for: UIControlState.normal)
        
        currentColor = colors[turn]
        progress.wipe = true
        progress.setNeedsDisplay()
        
        let names = [playerOneName, playerTwoName]
        turnLabel.text = "\(names[turn]?.text ?? "Player")'s turn"
    }
    
    func resetTimer() {
        timer.invalidate()
        clock = countdown
        startedTimer = false
        timeEffect?.stop()
    }
    
    @objc func updateTimer() {
        let arr = clock!.components(separatedBy: ".")
        let time = Int(arr[0])! * 10 + Int(arr[1])!
        
        if (time == 0) {
            endTurn(endTurnButton)
        } else {
            let newTime = time - 1
            clock = String(newTime / 10) + "." + String(newTime % 10)
        }
    }
    
    @IBAction func trophyDown(_ sender: UIButton) {
        displayingWin = true
        storedImage = self.imageView.image
        self.imageView.image = wins[turn]
    }
    
    @IBAction func trophyUp(_ sender: UIButton) {
        if (displayingWin) {
            self.imageView.image = storedImage
            displayingWin = false
        }
    }
    
    func similarity(input: UIImage) -> [Int] {
        
        // TODO YOU SHOULD PRECOMPUTE THE CENTER OF GRAVITY AND AVERAGE DISTANCE!!

        if self.imageView.image == nil {
            return [0, 0]
        }
        
        let playerOneTarget: Int32 = 255 - cv2.score(self.imageView.image!, to: #imageLiteral(resourceName: "winOne"))
        let playerTwoTarget: Int32 = 255 - cv2.score(self.imageView.image!, to: #imageLiteral(resourceName: "winTwo"))
        
        return [Int(100 * Float(playerOneTarget) / 255), Int(100 * Float(playerTwoTarget) / 255)]
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
