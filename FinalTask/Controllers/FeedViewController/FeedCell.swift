//
//  FeedCell.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 07.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

protocol NavigationFromFeedVC: class {
    func didPressButtonX(feedCell: FeedCell)
    func didPressUserPic(feedCell: FeedCell)
    func didPressLikes(postID: String)
    func didPressAvatarOrUserName(userID: String)
}

class FeedCell: UICollectionViewCell {
    
    weak var delegate: NavigationFromFeedVC?
    var post: Post!
    
    var indexPathItem: Int!
    
    let bigLike: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "bigLike")
        image.alpha = 0
        return image
    }()
    
    private let localizedLikes = NSLocalizedString("Likes ", comment: "")
    
    private let avatar: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .gray
        image.isUserInteractionEnabled = true
        return image
    }()
    
    private let userName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let addingDate: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let userPic: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .gray
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let likes: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let descriptionFeed: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var heartButton = UIButton(type: .system)
    private let stackHeader = UIStackView()
    private let stackLikesHeart = UIStackView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        heartButton.tintColor = .lightGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addElements()
        setConstraintsForAllElements()
        configureheartButton()
        addGestures()
        setBigLike()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeedCell {
    func configuretor (data: Post?, indexParhRow: Int, coreData: PostData?) {
        if let data = data {
            post = data
            let dateFormater = DateFormatter()
            dateFormater.dateStyle = .medium
            dateFormater.timeStyle = .medium
            
            if let url = URL(string: data.authorAvatar) {
                URLSession.shared.dataTask(with: url) { (data, _, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    if let imageData = data {
                        DispatchQueue.main.async {
                            self.avatar.image = UIImage(data: imageData)
                            CoreDataProvider.avatarsForPost[url.absoluteString] = imageData
                        }
                    }
                }.resume()
                
            }
            userName.text = data.authorUsername
            addingDate.text = data.createdTime
            if let url = URL(string: data.image) {
                URLSession.shared.dataTask(with: url) { (data, _, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    if let imageData = data {
                        DispatchQueue.main.async {
                            self.userPic.image = UIImage(data: imageData)
                            CoreDataProvider.imagesForPost[url.absoluteString] = imageData
                        }
                    }
                }.resume()
            }
            
            likes.text = localizedLikes + String(data.likedByCount)
            descriptionFeed.text  = data.description
            self.indexPathItem = indexParhRow
            if data.currentUserLikesThisPost == true {
                heartButton.tintColor = .systemBlue
            }
            
        } else if let coreData = coreData {
            userName.text = coreData.userFullName
            if let iData = coreData.avatarImage {
                avatar.image = UIImage(data: iData)
            }
            if let iData = coreData.postImage {
                userPic.image = UIImage(data: iData)
            }
            addingDate.text = coreData.createdTime
            descriptionFeed.text = coreData.postDescription
            likes.text = localizedLikes + (coreData.likedByCount ?? "")
            if coreData.currentUserLikesThisPost {
                heartButton.tintColor = .systemBlue
            }
        }
    }
}

private extension FeedCell {
    private func addElements() {
        stackHeader.addArrangedSubview(userName)
        stackHeader.addArrangedSubview(addingDate)
        stackHeader.axis = .vertical
        
        addSubview(avatar)
        addSubview(stackHeader)
        addSubview(userPic)
        addSubview(stackLikesHeart)
        addSubview(descriptionFeed)
        addSubview(bigLike)
        
        stackLikesHeart.addArrangedSubview(likes)
        stackLikesHeart.addArrangedSubview(heartButton)
        stackLikesHeart.axis = .horizontal
    }
    
    private func setConstraintsForAllElements() {
        
        avatar.anchor(top: topAnchor, left: leadingAnchor, paddingTop: 8, paddingLeft: 15)
        avatar.anchorSize(width: 35, height: 35)
        
        stackHeader.anchor(top: topAnchor, left: avatar.trailingAnchor, right: trailingAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 0)
        
        userPic.anchor(top: avatar.bottomAnchor, left: leadingAnchor, right: trailingAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
        userPic.anchorSize(width: frame.width - 20, height: frame.width - 20)
        
        stackLikesHeart.anchor(top: userPic.bottomAnchor, left: leadingAnchor, right: trailingAnchor, paddingTop: 0, paddingLeft: 15, paddingRight: 15)
        stackLikesHeart.anchorSize(height: 44)
        
        descriptionFeed.anchor(top: stackLikesHeart.bottomAnchor, left: leadingAnchor, right: trailingAnchor, paddingTop: 0, paddingLeft: 15, paddingRight: 15)
    }
    
    private func setBigLike() {
        bigLike.anchorCenterXY(centerX: userPic.centerXAnchor, centerY: userPic.centerYAnchor)
    }
    
    private func configureheartButton() {
        heartButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        heartButton.tintColor = .lightGray
        heartButton.anchorSize(width: 44, height: 44)
        heartButton.addTarget(self, action: #selector(addDeletLikes), for: .touchUpInside)
    }
    
    @objc func addDeletLikes(_ sender: UIButton) {
        delegate?.didPressButtonX(feedCell: self)
    }
    
    private func addGestures() {
        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(avatarAndUsernameHandle))
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(avatarAndUsernameHandle))
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(likesHandle))
        let gesture4 = UITapGestureRecognizer(target: self, action: #selector(userPicHandle))
        
        gesture4.numberOfTapsRequired = 2
        avatar.addGestureRecognizer(gesture1)
        userName.addGestureRecognizer(gesture2)
        likes.addGestureRecognizer(gesture3)
        userPic.addGestureRecognizer(gesture4)
    }
    
    @objc func avatarAndUsernameHandle() {
        delegate?.didPressAvatarOrUserName(userID: post.author)
    }
    
    @objc func likesHandle() {
        delegate?.didPressLikes(postID: post.id)
    }
    
    @objc func userPicHandle() {
        delegate?.didPressUserPic(feedCell: self)
    }
}
