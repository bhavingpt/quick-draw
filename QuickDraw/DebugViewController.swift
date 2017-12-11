//
//  DebugViewController.swift
//  QuickDraw
//
//  Created by Bhavin Gupta on 12/8/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController {
    
    @IBOutlet weak var one: UIImageView!
    @IBOutlet weak var two: UIImageView!
    @IBOutlet weak var three: UIImageView!
    @IBOutlet weak var four: UIImageView!
    
    let cv2 = OpenCVWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        one.image = #imageLiteral(resourceName: "winOne")
        two.image = #imageLiteral(resourceName: "debug")
        
        let out1: UIImage = cv2.process(one.image, to: two.image)
        three.image = one.image
        four.image = out1
        
        let score = cv2.score(three.image, to: four.image)
        
        print("received \(score)")
    }

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
