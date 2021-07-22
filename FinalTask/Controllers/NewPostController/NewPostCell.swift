//
//  NewPostCell.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 31.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class NewPostCell: UICollectionViewCell {
    let label = UILabel()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        addSubview(image)
        image.anchor(top: topAnchor, bottom: bottomAnchor, left: leadingAnchor, right: trailingAnchor)
        return image
    }()
    
    var imageGet: UIImage? {
        didSet {
            image.image = imageGet
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
    }
    
    func imageHGetFilter(image: UIImage, filter: String, queue: OperationQueue) {
        
        label.text = filter.replacingOccurrences(of: "Photo", with: "")
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 17)
        addSubview(label)
        
        let imageView = UIImageView()
        addSubview(imageView)
        
        imageView.anchorSize(width: 50, height: 50)
        imageView.anchor(top: topAnchor,
                         bottom: bottomAnchor,
                         left: leadingAnchor,
                         right: trailingAnchor,
                         paddingBottom: 30,
                         paddingLeft: 35,
                         paddingRight: 35)
        label.anchor(top: imageView.bottomAnchor,
                     bottom: bottomAnchor,
                     paddingTop: 8)
        label.anchorCenterXY(centerX: centerXAnchor)
        
        let operation = FilterImageOperation(inputImage: image, filter: filter)
        operation.completionBlock = {
            DispatchQueue.main.async {
                imageView.image = operation.outputImage
            }
        }
        
        queue.addOperation(operation)
    }
}
