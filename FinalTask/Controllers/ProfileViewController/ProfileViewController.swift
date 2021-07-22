//
//  Test.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 14.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ProfileViewController: UICollectionViewController {
    
    private let cellID = "cellID"
    private let headerIdentifier = "ProfileHeader"
    private let network = NetworkManager.shared
    
    private var posts = [Post]()
    private var userlocal: User!
    private var navigationTitle = NSLocalizedString("Profile", comment: "")
    private var isCurrent = false
    private var offlineImages = [UIImage]()
    
    override func viewDidLoad() {
        navigationItem.title = navigationTitle
        collectionView.backgroundColor = .white
        setupRegisters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if NetworkManager.isHaveConnection {
            guard let userlocal = userlocal else { return }
            network.getCurrentUser { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        if userlocal.id == user.id {
                            self.isCurrent = true
                            self.collectionView.reloadData()
                        }
                    case .failure(let error):
                        Alert.errorAlertFromServer(vc: self, message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func configurator(user: User) {
        userlocal = user
    }
    private func setupRegisters() {
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(ProfileCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
}
extension ProfileViewController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileCollectionHeader
        if NetworkManager.isHaveConnection {
        if userlocal == nil {
            self.startWaitingIndicator()
            network.getCurrentUser { (result) in
                DispatchQueue.main.async {
                    self.stopWaitingIndicator()
                    switch result {case .success(let user):
                        self.userlocal = user
                        CoreDataProvider.currentUser.append(user)
                        self.isCurrent = true
                        header.setHeaderData(data: user, userFromCD: nil, isCurrent: self.isCurrent)
                        header.logOut.isHidden = false
                        self.network.getUsersPosts(userID: self.userlocal.id) { (result) in
                            switch result {
                            case .success(let posts):
                                self.posts = posts
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            case .failure(let error):
                                Alert.errorAlertFromServer(vc: self, message: error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        Alert.errorAlertFromServer(vc: self, message: error.localizedDescription)
                    }
                }
            }
        } else if posts.isEmpty {
            
            network.getUsersPosts(userID: userlocal.id) { (result) in
                DispatchQueue.main.async {
                    self.stopWaitingIndicator()
                    switch result {
                    case .success(let result):
                        self.posts = result
                        header.setHeaderData(data: self.userlocal, userFromCD: nil, isCurrent: self.isCurrent)
                        header.followUnllow.isHidden = self.isCurrent
                        header.logOut.isHidden = !self.isCurrent
                        self.collectionView.reloadData()
                    case .failure(let error):
                        Alert.errorAlertFromServer(vc: self, message: error.localizedDescription)
                    }
                }
            }
        }
        } else {
            if offlineImages.isEmpty {
                for imageData in CoreDataProvider.imagesForUser{
                    offlineImages.append(UIImage(data: imageData.value) ?? UIImage())
                }
                let user = CoreDataProvider.currentUser.first
                header.setHeaderData(data: nil, userFromCD: user, isCurrent: true)
                header.currentUserImage.image = UIImage(data: CoreDataProvider.avatarForUser)
                collectionView.reloadData()
            }
         
        }
        
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NetworkManager.isHaveConnection ? posts.count : offlineImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProfileCell
        if NetworkManager.isHaveConnection {
            cell.image = posts[indexPath.row].image
            return cell

        } else {
            cell.offLineImage = offlineImages[indexPath.row]
            return cell
        }
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 86)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension ProfileViewController: NavigationFromProfileViewController {
    func logOutPressed() {
        NetworkManager.shared.logOut { (result) in
            switch result {
            case .success(let statusMessage):
                if statusMessage == "OK" {
                    DispatchQueue.main.async {
                        AppDelegate.shared.rootViewController.logOutPressed()
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func showFollowersTable() {
        self.startWaitingIndicator()
        network.getFollowersORFollowing(isFolowers: true, userID: userlocal.id) { (result) in
            DispatchQueue.main.async {
                self.stopWaitingIndicator()
                switch result {
                case .success(let users):
                    self.navigationController?.pushViewController(ProfileTableView(data: users, navTitle: NSLocalizedString("Followers", comment: "")), animated: true)
                case .failure(let error):
                    Alert.errorAlertFromServer(vc: self, message: error.localizedDescription)
                }
            }
        }
    }
    
    func showFollowingTable() {
        self.startWaitingIndicator()
        network.getFollowersORFollowing(isFolowers: false, userID: userlocal.id) { (result) in
            DispatchQueue.main.async {
                self.stopWaitingIndicator()
                switch result {
                case .success(let users):
                    self.navigationController?.pushViewController(ProfileTableView(data: users, navTitle: NSLocalizedString("Following", comment: "")), animated: true)
                case .failure(let error):
                    Alert.errorAlertFromServer(vc: self, message: error.localizedDescription)
                }
            }
        }
    }
    
}


