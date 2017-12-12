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
        three.image = #imageLiteral(resourceName: "winTwo")
        four.image = cv2.process(one.image, to: two.image)
        var score: Int32;
    
        print("\n\n------------------ basic checks ------------\n\n");
      
        print("scoring reference house against reference house")
        score = cv2.hausdorff_wrap(one.image, to: one.image)
        print("received \(score)\n")
        
        print("scoring reference flower against reference flower")
        score = cv2.hausdorff_wrap(three.image, to: three.image)
        print("received \(score)\n")
        
        print("\n\n------------------ shitty checks ------------\n\n");
 
        print("scoring shitty house against reference house")
        score = cv2.hausdorff_wrap(two.image, to: one.image)
        print("received \(score)\n")
        
        print("scoring shitty house against reference flower")
        score = cv2.hausdorff_wrap(two.image, to: three.image)
        print("received \(score)\n")
        
        print("\n\n------------------ modified checks ------------\n\n");
        
        print("scoring modified house against reference house")
        score = cv2.hausdorff_wrap(four.image, to: one.image)
        print("received \(score)\n")
        
        print("scoring modified house against reference flower")
        score = cv2.hausdorff_wrap(four.image, to: three.image)
        print("received \(score)\n")
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
