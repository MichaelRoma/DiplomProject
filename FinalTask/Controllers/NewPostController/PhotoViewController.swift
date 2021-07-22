//
//  PhotoViewController.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 01.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class PhotoViewController: UIViewController {
    
    private let localFilters = NSLocalizedString("Filters", comment: "")
    private let localNext = NSLocalizedString("Next", comment: "")
    
    private let queue = OperationQueue()
    private let filters = Filters()
    
    let image = UIImageView()
    let thumbnailImage = UIImageView()
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        let next = UIBarButtonItem(title: localNext, style: .done, target: self, action: #selector(goNext))
               navigationItem.rightBarButtonItem = next
    }
    
    func configurator(image: UIImage, thumbnailImage: UIImage) {
        self.image.image = image
        self.thumbnailImage.image = thumbnailImage
    }
    
    @objc private func goNext() {
        let goView = ShareViewController()
        goView.image.image = image.image
        navigationController?.pushViewController(goView, animated: true)
         }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = localFilters
        view.addSubview(image)
        view.addSubview(collectionView)
        
        collectionView.register(NewPostCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        
        collectionView.anchor(bottom: view.bottomAnchor, left: view.leadingAnchor, right: view.trailingAnchor, paddingBottom: 80, paddingLeft: 0, paddingRight: 0)
        collectionView.anchorSize(height: 90)
        
        image.anchor(top: view.topAnchor, left: view.leadingAnchor, right: view.trailingAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filters.filterArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NewPostCell
        
        let filter = filters.filterArray[indexPath.item]
        guard let thumbnailImage = thumbnailImage.image else { return cell}
        
        cell.imageHGetFilter(image: thumbnailImage, filter: filter, queue: queue)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let operation = FilterImageOperation(inputImage: image.image, filter: filters.filterArray[indexPath.item])
        operation.completionBlock = {
            DispatchQueue.main.async {
                self.image.image = operation.outputImage
                self.stopWaitingIndicator()
            }
        }
        startWaitingIndicator()
        queue.addOperation(operation)
    }
}
