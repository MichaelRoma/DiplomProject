//
//  ProfileVCTest.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 11.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class ProfileViewControllerOLD: UIViewController {
 private let queue = DispatchQueue.global(qos: .userInitiated)
 
 private let cellID = "cellID"
 private let headerIdentifier = "ProfileHeader"
    
 private let layout: UICollectionViewFlowLayout
    
 private var posts: [Post]!
    private var userlocal: User!
 private var navigationTitle: String = "Profile"
    
 private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProfileCollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellID)
    return collectionView
    }()
    

    
 required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
    }
    
 override func viewDidLoad() {
    super.viewDidLoad()
   // collectionView.backgroundView
    view.addSubview(collectionView)
    navigationItem.title = navigationTitle
    }
    
 override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.frame = .init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
}

extension ProfileViewControllerOLD: UICollectionViewDataSource {
    
 func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileCollectionHeader
        header.setHeaderData(data: userlocal)
        header.delegate = self
    return header
    }
    
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return posts.count
    }
    
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProfileCell
        cell.image = posts[indexPath.row].image
    return cell
    }
}

extension ProfileViewControllerOLD: UICollectionViewDelegateFlowLayout {
    
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

extension ProfileViewControllerOLD: NavigationFromProfileViewController {
    
 func showFollowersTable() {

    DataProviders.shared.usersDataProvider.usersFollowedByUser(with: userlocal.id, queue: queue) { [weak self] (users) in
        guard let users = users else {return}
        DispatchQueue.main.async {
            self?.navigationController?.pushViewController(ProfileTableView(data: users, navTitle: "Followers"), animated: true)
        }
            }
    }
    
 func showFollowingTable() {
    DataProviders.shared.usersDataProvider.usersFollowingUser(with: userlocal.id, queue: queue) { [weak self] (users) in
           guard let users = users else {return}
           DispatchQueue.main.async {
               self?.navigationController?.pushViewController(ProfileTableView(data: users, navTitle: "Following"), animated: true)
           }
       }
    }
}
