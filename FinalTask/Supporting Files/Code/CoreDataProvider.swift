//
//  CoreDataProvider.swift
//  FinalTask
//
//  Created by Mykhailo Romanovskyi on 07.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//
import UIKit

class CoreDataProvider {
    static var posts = [Post]()
    static var avatarsForPost = [String: Data]()
    static var imagesForPost = [String: Data]()
    
    static var currentUser = [User]()
    static var avatarForUser = Data()
    static var avatarOffLine = UIImage()
    static var imagesForUser = [String: Data]()
    
    static var userFromCore = [UserData]() {
        willSet {
        print("Just set data")
        }
    }
}
