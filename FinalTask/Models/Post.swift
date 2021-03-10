//
//  Post.swift
//  FinalTask
//
//  Created by Mykhailo Romanovskyi on 11.11.2020.
//  Copyright © 2020 e-Legion. All rights reserved.

//Модель для получения данных про посты
struct Post: Codable {
    let id: String
    let description: String
    let image: String
    let createdTime: String
    let currentUserLikesThisPost: Bool
    var likedByCount: Int
    let author: String
    let authorUsername: String
    let authorAvatar: String
}
