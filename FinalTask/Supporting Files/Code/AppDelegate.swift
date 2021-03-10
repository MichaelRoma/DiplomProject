//
//  AppDelegate.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let dataManager = CoreDataManager(modelName: "BackUpData2")
 
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        assembly()
        return true
    }
    
    //Метод который вызывается когда приложение закрывается. Надо будет использовать при сохранение базы.
    func applicationWillTerminate(_ application: UIApplication) {
        let context = dataManager.getContext()

        let userCD = dataManager.createObject(from: UserData.self)
        userCD.avatarImage = CoreDataProvider.avatarForUser
        userCD.fullName = CoreDataProvider.currentUser.first?.fullName
        userCD.username = CoreDataProvider.currentUser.first?.username
        userCD.currentUserFollowsThisUser = CoreDataProvider.currentUser.first?.currentUserFollowsThisUser ?? false
        userCD.currentUserIsFollowedByThisUser = CoreDataProvider.currentUser.first?.currentUserIsFollowedByThisUser ?? false
        userCD.followedByCount = String(CoreDataProvider.currentUser.first?.followedByCount ?? 0)
        userCD.followsCount = String(CoreDataProvider.currentUser.first?.followsCount ?? 0)
        dataManager.save(context: context)
        
        for image in CoreDataProvider.imagesForUser {
            let imageCD = dataManager.createObject(from: UserPosts.self)
            imageCD.postImage = image.value
        }
        
        for post in CoreDataProvider.posts {

            let postCD = dataManager.createObject(from: PostData.self)
            postCD.avatarImage = CoreDataProvider.avatarsForPost[post.authorAvatar]
            postCD.postImage = CoreDataProvider.imagesForPost[post.image]

            postCD.userNickName = post.author
            postCD.userFullName = post.authorUsername
            postCD.createdTime = post.createdTime
            postCD.id = post.id
            postCD.likedByCount = String(post.likedByCount)
            postCD.postDescription = post.description
            postCD.currentUserLikesThisPost = post.currentUserLikesThisPost
            dataManager.save(context: context)
        }
    }
}

private extension AppDelegate {
    func assembly() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
    }
}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var rootViewController: RootViewController {
        return window?.rootViewController as! RootViewController
    }
}
