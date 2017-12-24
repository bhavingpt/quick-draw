//
//  HomeViewController.swift
//  QuickDraw
//
//  Created by Bhavin Gupta on 12/14/17.
//  Copyright © 2017 bhavingpt. All rights reserved.
//

import UIKit

class HomeViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let light_purple = UIColor.init(red: CGFloat(50)/255, green: CGFloat(162)/255, blue: CGFloat(208)/255, alpha: 1.0)

        tabBar.unselectedItemTintColor = light_purple
        tabBar.tintColor = UIColor.white
        let tabBarItems = tabBar.items! as [UITabBarItem]
        for item in tabBarItems {
            item.title = nil
            item.imageInsets = UIEdgeInsetsMake(6,0,-6,0)
        }
        

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
