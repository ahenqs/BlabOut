//
//  TabBarController.swift
//  BlabOut
//
//  Created by André Henrique da Silva on 10/07/2016.
//  Copyright © 2016 André Henrique da Silva. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let feedController = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let navController = UINavigationController(rootViewController: feedController)
        let feedIcon = UITabBarItem(title: "Me", image: UIImage(named: "tabUser"), tag: 0)
        feedController.tabBarItem = feedIcon
        
        let timelineController = TimelineController(collectionViewLayout: UICollectionViewFlowLayout())
        let timelineIcon = UITabBarItem(title: "Timeline", image: UIImage(named: "tabUser"), tag: 0)
        timelineController.tabBarItem = timelineIcon
        
        let usersController = UsersController()
        let usersIcon = UITabBarItem(title: "Users", image: UIImage(named: "tabUser"), tag: 0)
        usersController.tabBarItem = usersIcon
        
        let usersNavController = UINavigationController(rootViewController: usersController)
        
        let controllers = [navController, timelineController, usersNavController]
        
        self.viewControllers = controllers
    }

    override func viewDidAppear(_ animated: Bool) {
        
        self.selectedIndex = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
