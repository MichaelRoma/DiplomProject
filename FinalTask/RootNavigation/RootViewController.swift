//
//  RootViewController.swift
//  FinalTask
//
//  Created by Mykhailo Romanovskyi on 21.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {
    
    private var current: UIViewController
    
    init() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        current = loginVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self)
    }
    
    func switchToMainTabBarController() {
        let mainScreen = assemblyMainTabBarController()
        addChild(mainScreen)
        mainScreen.view.frame = view.bounds
        view.addSubview(mainScreen.view)
        mainScreen.didMove(toParent: self)
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = mainScreen
    }
    
    func logOutPressed() {
        _ = KeychainManger.shared.deleteToken()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        addChild(loginVC)
        loginVC.view.frame = view.bounds
        view.addSubview(loginVC.view)
        loginVC.didMove(toParent: self)
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = loginVC
    }
}

private extension RootViewController {
    func assemblyMainTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let feedVC = UINavigationController(rootViewController: FeedViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        feedVC.tabBarItem.image = #imageLiteral(resourceName: "feed")
        feedVC.tabBarItem.title = NSLocalizedString("Feed", comment: "")
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        profileVC.tabBarItem.image = #imageLiteral(resourceName: "profile")
        profileVC.tabBarItem.title = NSLocalizedString("Profile", comment: "")
        
        let newPostVC = UINavigationController(rootViewController: NewPostViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        newPostVC.tabBarItem.image = #imageLiteral(resourceName: "plus")
        newPostVC.tabBarItem.title = NSLocalizedString("New Post", comment: "")
        
        tabBarController.viewControllers = [feedVC, newPostVC, profileVC]
        return tabBarController
    }
}
