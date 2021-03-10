//
//  ProfileCell.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 07.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//
import UIKit
import Kingfisher

class ProfileCell: UICollectionViewCell {
    
    var image: String? {
        didSet {
            if NetworkManager.isHaveConnection {
                if let url = URL(string: image ?? "") {
                    URLSession.shared.dataTask(with: url) { (data, _, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        if let imageData = data {
                            DispatchQueue.main.async {
                                self.userImage.image = UIImage(data: imageData)
                                CoreDataProvider.imagesForUser[url.absoluteString] = imageData
                            }
                        }
                    }.resume()
                }
            } else { //Тут будет присвоение картнинки с кор дата
                
            }
        }
    }
    
    var offLineImage: UIImage? {
        didSet {
            userImage.image = offLineImage
        }
    }
    
    private lazy var userImage: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.clipsToBounds = true
        return imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(userImage)
        userImage.anchor(top: topAnchor, bottom: bottomAnchor, left: leadingAnchor, right: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
