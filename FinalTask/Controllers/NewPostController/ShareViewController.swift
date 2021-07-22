//
//  ShareViewController.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 03.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

final class ShareViewController: UIViewController {
    
    private let localShare = NSLocalizedString("Share", comment: "")
    private let localAddDescript = NSLocalizedString("Add description", comment: "")
    private let localPlaceholder = NSLocalizedString("Type text, press return -> can Share", comment: "")
    
    let image = UIImageView()
    let network = NetworkManager.shared
    
    private let textfield = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        let share = UIBarButtonItem(title: localShare, style: .done, target: self, action: #selector(sharePost))
        navigationItem.rightBarButtonItem = share
        navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    @objc private func sharePost() {
        network.createPost(image: image.image!, description: textfield.text!) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    if result == "OK" {
                        self.tabBarController?.selectedIndex = 0
                    } else {
                        Alert.errorAlertFromServer(vc: self, message: result)
                    }
                case .failure(let error):
                    Alert.errorAlertFromServer(vc: self, message: error.localizedDescription)
                }
            }
        }
        
    }
    private func setupViews() {
        
        let label = UILabel()
        
        view.addSubview(image)
        view.addSubview(label)
        view.addSubview(textfield)
        
        image.anchorSize(width: 100, height: 100)
        image.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     left: view.leadingAnchor,
                     paddingTop: 16,
                     paddingLeft: 16)
        label.anchor(top: image.bottomAnchor,
                     left: view.leadingAnchor,
                     paddingTop: 32,
                     paddingLeft: 16)
        textfield.anchor(top: label.bottomAnchor,
                         left: view.leadingAnchor,
                         right: view.trailingAnchor,
                         paddingTop: 8,
                         paddingLeft: 16,
                         paddingRight: 16)
        
        image.backgroundColor = .red
        
        label.text = localAddDescript
        
        view.backgroundColor = .white
        
        textfield.font = UIFont.systemFont(ofSize: 17)
        textfield.placeholder = localPlaceholder
        textfield.borderStyle = .roundedRect
        textfield.delegate = self
    }
}

extension ShareViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
