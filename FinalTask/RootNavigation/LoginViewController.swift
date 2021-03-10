//
//  LoginViewController.swift
//  FinalTask
//
//  Created by Mykhailo Romanovskyi on 21.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var user: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user.delegate = self
        password.delegate = self
        disableSignIn()
        
        let dataManager = CoreDataManager(modelName: "BackUpData2")
        _ = dataManager.fetchData(for: PostData.self)
        let user = dataManager.fetchData(for: UserData.self)
        let userImages = dataManager.fetchData(for: UserPosts.self)
        
        for (key, image) in userImages.enumerated() {
            CoreDataProvider.imagesForUser["\(key)"] = image.postImage
        }
        if let currentUSer = user.first {
            CoreDataProvider.userFromCore.append(currentUSer)
            CoreDataProvider.avatarForUser = currentUSer.avatarImage ?? Data()
        }
        
        if let user = CoreDataProvider.userFromCore.first {
            guard let current = User(with: user) else { return }
            CoreDataProvider.currentUser.append(current)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForToken()
    }
    
    @IBAction func pressedSignIn(_ sender: UIButton) {
        if let user = user.text, let password = password.text, !user.isEmpty, !password.isEmpty {
            LogingToServer(login: user, password: password)
        } else {
            disableSignIn()
        }
    }
}

// MARK: Text Field Delegat
extension LoginViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == user {
            password.becomeFirstResponder()
        } else if let user = user.text, let password = password.text, !user.isEmpty, !password.isEmpty  {
            enableSignIn()
            LogingToServer(login: user, password: password)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if user.text!.isEmpty || password.text!.isEmpty {
            disableSignIn()
        } else if !signIn.isEnabled {
            enableSignIn()
        }
    }
}

//MARK: Private Functions
extension LoginViewController {
    
    private func disableSignIn() {
        signIn.isEnabled = false
        signIn.alpha = 0.3
    }
    
    private func enableSignIn() {
        signIn.isEnabled = true
        signIn.alpha = 1
    }
    
    private func checkForToken() {
        NetworkManager.shared.checkToken { (result) in
            switch result {
            case .success(let codeMessage):
                if codeMessage == "OK" {
                    DispatchQueue.main.async {
                        AppDelegate.shared.rootViewController.switchToMainTabBarController()
                    }
                } else {
                    _ = KeychainManger.shared.deleteToken()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    NetworkManager.isHaveConnection = false
                    Alert.showAlert(vc: self)
                }
            }
        }
    }
    
    private func LogingToServer(login: String, password: String) {
        NetworkManager.shared.logIn(login: login, password: password) { (result) in
            switch result {
      
            case .success(let codeMessage):
                switch codeMessage {
                case "OK":

                    let dataManager = CoreDataManager(modelName: "BackUpData2")
                    let store = dataManager.fetchData(for: PostData.self)
                    let users = dataManager.fetchData(for: UserData.self)
                    let images = dataManager.fetchData(for: UserPosts.self)
                    
                    let context = dataManager.getContext()
                    images.forEach { (image) in
                        dataManager.delete(object: image)
                    }
                    store.forEach { (item) in
                        dataManager.delete(object: item)
                    }
                    if let user = users.first {
                        dataManager.delete(object: user) }
                    
                    dataManager.save(context: context)
                    DispatchQueue.main.async {
                        AppDelegate.shared.rootViewController.switchToMainTabBarController()
                    }
                    
                    
                case "Unauthorized":
                    DispatchQueue.main.async {
                        Alert.erroAlertFromServer(vc: self, message: codeMessage)
                    }
                default:
                    NetworkManager.isHaveConnection = false
                    DispatchQueue.main.async {
                        AppDelegate.shared.rootViewController.switchToMainTabBarController()
                    }
                }
                
            case .failure(_):
                DispatchQueue.main.async {
                    NetworkManager.isHaveConnection = false
                    AppDelegate.shared.rootViewController.switchToMainTabBarController()
                }
            }
        }
    }
}
