//
//  NewPostViewController.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 31.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PostCell"

final class NewPostViewController: UICollectionViewController {

    let photos = [UIImage(named: "new1.jpg"),
                  UIImage(named: "new2.jpg"),
                  UIImage(named: "new3.jpg"),
                  UIImage(named: "new4.jpg"),
                  UIImage(named: "new5.jpg"),
                  UIImage(named: "new6.jpg"),
                  UIImage(named: "new7.jpg"),
                  UIImage(named: "new8.jpg")]
    
    let thumbnailPhotos = [UIImage(named: "new1.jpg"),
                    UIImage(named: "new2.jpg"),
                    UIImage(named: "new3.jpg"),
                    UIImage(named: "new4.jpg"),
                    UIImage(named: "new5.jpg"),
                    UIImage(named: "new6.jpg"),
                    UIImage(named: "new7.jpg"),
                    UIImage(named: "new8.jpg")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.register(NewPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        navigationItem.title = NSLocalizedString("New Post", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !NetworkManager.isHaveConnection {
            let alert = UIAlertController(title: "Server Error", message: "OFFLINE Mode. CLick OK to go back to feedView", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ _ in
                self.tabBarController?.selectedIndex = 0
            }))
            present(alert, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NewPostCell
        cell.imageGet = photos[indexPath.item]
        return cell
    }
}

extension NewPostViewController: UICollectionViewDelegateFlowLayout {
    
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        let pushToThisView = PhotoViewController()
        pushToThisView.configurator(image: photos[indexPath.item]!, thumbnailImage: thumbnailPhotos[indexPath.item]!)
        self.navigationController?.pushViewController(pushToThisView, animated: true)
    }
}
