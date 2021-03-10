//
//  ProfileCollectionHeader.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 07.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//
import UIKit

protocol NavigationFromProfileViewController: class {
    func showFollowersTable()
    func showFollowingTable()
    func logOutPressed()
}

class ProfileCollectionHeader: UICollectionReusableView {
    private let network = NetworkManager.shared
    private var user: User!
    weak var delegate: NavigationFromProfileViewController?
    
    private let localFollowers = NSLocalizedString("Followers: ", comment: "")
    private let localFollowing = NSLocalizedString("Following: ", comment: "")
    private let localFollowButton = NSLocalizedString("Follow", comment: "")
    private let localUnfollowButton = NSLocalizedString("UnFollow", comment: "")
    private let localLogout = NSLocalizedString("Logout", comment: "")
    
    
     lazy var currentUserImage: UIImageView = {
        let imageview = UIImageView()
        imageview.layer.cornerRadius = 35
        imageview.clipsToBounds = true
        return imageview
    }()
    
    private lazy var nameTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "System", size: 14)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var followUnllow: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 1, alpha: 1)
        button.titleEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.layer.cornerRadius = 10
        button.setTitle(localUnfollowButton, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(followUnllowAction), for: .touchUpInside)
        return button
    }()
    
    lazy var logOut: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5882352941, blue: 1, alpha: 1)
        button.titleEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.layer.cornerRadius = 10
        button.setTitle(localLogout, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(logOutAction), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addElements()
        setConstraints()
        setGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProfileCollectionHeader {
    
    func setHeaderData(data: User?, userFromCD: User?, isCurrent: Bool) {
        if let data = data {
            user = data
            if let url = URL(string: user.avatar) {
                //  userImage.kf.setImage(with: url)
                URLSession.shared.dataTask(with: url) { (data, _, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    if let imageData = data {
                        DispatchQueue.main.async {
                            self.currentUserImage.image = UIImage(data: imageData)
                            if isCurrent {
                                CoreDataProvider.avatarForUser = imageData
                            }
                        }
                    }
                }.resume()
            }
            nameTextLabel.text = data.fullName
            followersLabel.text = localFollowers + String(data.followedByCount)
            followingLabel.text = localFollowing + String(data.followsCount)
            if !data.currentUserFollowsThisUser {
                followUnllow.setTitle(localFollowButton, for: .normal)
            }
        } else if let userFromCD = userFromCD {
           // currentUserImage.image = UIImage(data: userFromCD.avatarImage ?? Data())
            nameTextLabel.text = userFromCD.fullName
            followersLabel.text = localFollowers + "\(userFromCD.followedByCount)"
            followingLabel.text = localFollowing + "\(userFromCD.followsCount)"
        }
    }
}

private extension ProfileCollectionHeader {
    
    func addElements() {
        addSubview(currentUserImage)
        addSubview(nameTextLabel)
        addSubview(followersLabel)
        addSubview(followingLabel)
        
        addSubview(followUnllow)
        addSubview(logOut)
    }
    
    func setConstraints() {
        currentUserImage.anchor(top: topAnchor, left: leadingAnchor, paddingTop: 8, paddingLeft: 8)
        currentUserImage.anchorSize(width: 70, height: 70)
        
        nameTextLabel.anchor(top: topAnchor, left: currentUserImage.trailingAnchor, paddingTop: 8, paddingLeft: 8)
        
        followersLabel.anchor(bottom: bottomAnchor, left: currentUserImage.trailingAnchor, paddingBottom: 8, paddingLeft: 8)
        
        followingLabel.anchor( bottom: bottomAnchor, right: trailingAnchor,  paddingBottom: 8, paddingRight: 16)
        
        followUnllow.anchor(top: topAnchor, right: trailingAnchor, paddingTop: 10, paddingRight: 10)
        followUnllow.anchorSize(width: 80)
        
        logOut.anchor(top: topAnchor, right: trailingAnchor, paddingTop: 10, paddingRight: 10)
        logOut.anchorSize(width: 80)
    }
    
    func setGestureRecognizer() {
        let gestureFollowers = UITapGestureRecognizer(target: self, action: #selector(showFollowers))
        let gestureFollowing = UITapGestureRecognizer(target: self, action: #selector(showFollowing))
        followersLabel.addGestureRecognizer(gestureFollowers)
        followingLabel.addGestureRecognizer(gestureFollowing)
    }
    
    @objc func showFollowers() {
        delegate?.showFollowersTable()
    }
    
    @objc func showFollowing() {
        delegate?.showFollowingTable()
    }
    
    @objc func followUnllowAction() {
        if followUnllow.titleLabel?.text == localFollowButton {
            followUnllow.setTitle(localUnfollowButton, for: .normal)
            network.followORunfollow(wantFollow: true, userID: user.id) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        self.user = user
                        self.followersLabel.text = self.localFollowers + String(user.followedByCount)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            followUnllow.setTitle(localFollowButton, for: .normal)
            network.followORunfollow(wantFollow: false, userID: user.id) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        self.user = user
                        self.followersLabel.text = self.localFollowers + String(user.followedByCount)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @objc func logOutAction() {
        delegate?.logOutPressed()
    }
}

