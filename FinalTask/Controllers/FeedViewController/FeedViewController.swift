//
//  FeedVC.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 06.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class FeedViewController: UICollectionViewController {
    private let reuseIdentifier = "FeedCell"
    private let network = NetworkManager.shared
    let dataManager = CoreDataManager(modelName: "BackUpData2")
    var feedPosts = [Post]()
    private var store: [PostData]!
    
    override func viewWillAppear(_ animated: Bool) {
        if NetworkManager.isHaveConnection {
            startWaiting()
            network.fetchData { (result) in
                switch result {
                case .success(let posts):
                    self.feedPosts = posts
                    CoreDataProvider.posts = posts
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.stopWaiting()
                    }
                case .failure(let error):
                    Alert.erroAlertFromServer(vc: self, message: error.localizedDescription)
                }
            }
        } else {
            store = dataManager.fetchData(for: PostData.self)
            collectionView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white

        navigationItem.title = NSLocalizedString("Feed", comment: "")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if NetworkManager.isHaveConnection {
            return feedPosts.count
        } else {
            guard let store = store else { return 0}
            return store.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        if NetworkManager.isHaveConnection {
            cell.configuretor(data: feedPosts[indexPath.item], indexParhRow: indexPath.item, coreData: nil) }
        else {
            guard store != nil else { return cell}
            cell.configuretor(data: nil, indexParhRow: indexPath.item, coreData: store[indexPath.item])
        }
        cell.delegate = self
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 550)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {        return 0
    }
}

// MARK: extension for Delegat
extension FeedViewController: NavigationFromFeedVC {
    
    func didPressAvatarOrUserName(userID: String) {
        startWaiting()
        network.getUserByID(userID: userID) { (result) in
            DispatchQueue.main.async {
                self.stopWaiting()
                switch result {
                case .success(let result):
                    let profile = ProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
                    profile.configurator(user: result)
                    self.navigationController?.pushViewController(profile, animated: true)
                case .failure(let error):
                    Alert.erroAlertFromServer(vc: self, message: error.localizedDescription)
                }
            }
        }
    }
    
    func didPressLikes(postID: String) {
        startWaiting()
        network.getLikedPosts(postID: postID) { (result) in
            DispatchQueue.main.async {
                self.stopWaiting()
                switch result {
                case .success(let users):
                    self.navigationController?.pushViewController(ProfileTableView(data: users, navTitle: NSLocalizedString("Likes ", comment: "")), animated: true)
                case .failure(let erorr):
                    Alert.erroAlertFromServer(vc: self, message: erorr.localizedDescription)
                }
            }
        }
    }
    
    
    func didPressButtonX(feedCell: FeedCell) {
        let localizedLikes = NSLocalizedString("Likes ", comment: "")
        switch feedCell.heartButton.tintColor {
        case UIColor.lightGray:
            self.startWaiting()
            network.likeORunlikeTHisPost(isLike: true, postId: feedCell.post.id) { (result) in
                DispatchQueue.main.async {
                    self.stopWaiting()
                    switch result {
                    case .success(let response):
                        if response != "OK" {
                            Alert.erroAlertFromServer(vc: self, message: response)
                            return
                        }
                        self.feedPosts[feedCell.indexPathItem].likedByCount += 1
                        let liked = self.feedPosts[feedCell.indexPathItem].likedByCount
                        feedCell.post.likedByCount += 1
                        feedCell.likes.text = localizedLikes + String(liked)
                        feedCell.heartButton.tintColor = .systemBlue
                        
                    case .failure(let error):
                        Alert.erroAlertFromServer(vc: self, message: error.localizedDescription)
                    }
                }
            }
            
        case UIColor.systemBlue:
            self.startWaiting()
            network.likeORunlikeTHisPost(isLike: false, postId: feedCell.post.id) { (result) in
                DispatchQueue.main.async {
                    self.stopWaiting()
                    switch result {
                    case .success(let response):
                        if response != "OK" {
                            Alert.erroAlertFromServer(vc: self, message: response)
                            return
                        }
                        self.feedPosts[feedCell.indexPathItem].likedByCount -= 1
                        let liked = self.feedPosts[feedCell.indexPathItem].likedByCount
                        feedCell.post.likedByCount -= 1
                        feedCell.likes.text = localizedLikes + String(liked)
                        feedCell.heartButton.tintColor = .lightGray
                        
                    case .failure(let error):
                        Alert.erroAlertFromServer(vc: self, message: error.localizedDescription)
                    }
                }
            }
        default:
            print("Something went wrong")
        }
    }
    
    func didPressUserPic(feedCell: FeedCell) {
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.opacity))
        let values = [0, 1, 0]
        let timeFrames = [0.1, 0.2, 0.3]
        animation.values = values
        animation.keyTimes = timeFrames as [NSNumber]
        animation.duration = 3
        let firstStep = CAMediaTimingFunction(name: .linear)
        let secondStep = CAMediaTimingFunction(name: .default)
        let thirdStep = CAMediaTimingFunction(name: .easeOut)
        animation.timingFunctions = [firstStep, secondStep, thirdStep]
        feedCell.bigLike.layer.add(animation, forKey: nil)
        
        if feedCell.heartButton.tintColor == UIColor.lightGray {
            self.startWaiting()
            network.likeORunlikeTHisPost(isLike: true, postId: feedCell.post.id) { (result) in
                DispatchQueue.main.async {
                    self.stopWaiting()
                    switch result {
                    case .success(let response):
                        if response != "OK" {
                            Alert.erroAlertFromServer(vc: self, message: response)
                            return
                        }
                        self.feedPosts[feedCell.indexPathItem].likedByCount += 1
                        let liked = self.feedPosts[feedCell.indexPathItem].likedByCount
                        feedCell.likes.text = NSLocalizedString("Likes ", comment: "") + String(liked)
                        feedCell.heartButton.tintColor = .systemBlue
                        
                    case .failure(let error):
                        Alert.erroAlertFromServer(vc: self, message: error.localizedDescription)
                    }
                }
            }
        }
    }
}
