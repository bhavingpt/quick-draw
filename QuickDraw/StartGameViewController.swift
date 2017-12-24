//
//  StartGameViewController.swift
//  QuickDraw
//
//  Created by Bhavin Gupta on 12/14/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

import UIKit

class StartGameViewController: UIViewController {

    @IBOutlet weak var bonusView: UIView!
    @IBOutlet weak var coins: UIButton!
    @IBOutlet weak var newGame: UIButton!
    @IBOutlet weak var coinsOwned: UIView!
    @IBOutlet weak var inkOwned: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Shadow and Radius for Circle Button
        coins.layer.cornerRadius = 20
        bonusView.layer.cornerRadius = 20
        newGame.layer.cornerRadius = 20
        
        coinsOwned.layer.cornerRadius = 7
        inkOwned.layer.cornerRadius = 7

        // Do any additional setup after loading the view.
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
