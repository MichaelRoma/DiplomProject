//
//  UserM.swift
//  FinalTask
//
//  Created by Mykhailo Romanovskyi on 31.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//Модель для пользователя
struct User: Codable {
    let id: String
    let username: String
    let fullName: String
    let avatar: String
    let currentUserFollowsThisUser: Bool
    let currentUserIsFollowedByThisUser: Bool
    let followsCount: Int
    let followedByCount: Int
    
    init?(with data: UserData) {
        self.id = "only current user"
        self.username = data.username ?? ""
        self.fullName = data.fullName ?? ""
        self.avatar = "NO"
        self.currentUserFollowsThisUser = false
        self.currentUserIsFollowedByThisUser = false
        if let followsCount = data.followsCount, let number = Int(followsCount) {
            self.followsCount = number } else {
                self.followsCount = 0
            }
        if let followedByCount = data.followedByCount, let number = Int(followedByCount) {
            self.followedByCount = number } else {
                self.followedByCount = 0
            }
    }
}
