//
//  ProfileTVCell.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 08.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileTableViewCell: UITableViewCell {
    
    private let imageUserCell = UIImageView()
    private let userNameCell = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configImageCell()
        configNameCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProfileTableViewCell {
    func setCellProperty(image: String, text: String) {
        if let url = URL(string: image) {
            imageUserCell.kf.setImage(with: url)
        }
        userNameCell.text = text
    }
}

private extension ProfileTableViewCell {
    
    func configImageCell() {
        addSubview(imageUserCell)
        imageUserCell.anchor(top: topAnchor, bottom: bottomAnchor, left: leadingAnchor, paddingTop: 0, paddingBottom: 1, paddingLeft: 15)
        imageUserCell.anchorSize(width: 43)
    }
    
    func configNameCell() {
        addSubview(userNameCell)
        userNameCell.anchor(left: imageUserCell.trailingAnchor, right: trailingAnchor, paddingLeft: 16, paddingRight: 0)
        userNameCell.anchorCenterXY(centerY: centerYAnchor)
        userNameCell.font = UIFont.systemFont(ofSize: 17)
    }
}
