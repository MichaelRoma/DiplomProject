//
//  NetworkManager.swift
//  FinalTask
//
//  Created by Mykhailo Romanovskyi on 23.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

class NetworkManager {
    static var isHaveConnection = true
    
    private let hostPath = "http://localhost:8080"
    
    private let signIn = "signin"
    private let signOut = "signout"
    
    private let posts = "posts"
    private let feed = "/feed"
    private let like = "/like"
    private let unlike = "/unlike"
    private let currentUser = "users/me"
    private let users = "users"
    
    private let followers = "/followers"
    private let following = "/following"
    
    private let follow = "/follow"
    private let unfollow = "/unfollow"
    
    private let create = "/create"
    
    private let headerForJosn = ["Content-Type":"application/json"]
    
    private let chekToken = "/checkToken"
    
    let session = URLSession.shared
    
    private enum httpMethod: String {
        case POST
        case GET
    }
    
    private var login = "user"
    static var shared = NetworkManager()
    private init() {}
    
    //MARK: CheckToken
    func checkToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: chekToken,
                                        method: httpMethod.GET.rawValue,
                                        header: ["token":token],
                                        body: nil) else { return }
        
        session.dataTask(with: request) { (_, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse {
                completion(.success(self.getMessageFromCode(code: response.statusCode)))
            }
        }.resume()
    }
    
    
    // MARK: LOGIN
    func logIn(login: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        self.login = login
        let data = ["login": login,"password": password]
        let jsonData =  try? JSONSerialization.data(withJSONObject: data, options: [])
        
        guard let request = generateRequest(for: signIn,
                                            method: httpMethod.POST.rawValue,
                                            header: headerForJosn,
                                            body: jsonData) else { return }
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data, let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:String]
                    guard let token = json?["token"] else { return }
                    _ = KeychainManger.shared.saveToken(newToken: token, account: login)
                    completion(.success(self.getMessageFromCode(code: response.statusCode)))
                    
                } else {
                    completion(.success(self.getMessageFromCode(code: response.statusCode)))
                }
            }
        }.resume()
    }
    
    // MARK: LOGOUT
    func logOut(completion: @escaping (Result<String, Error>) -> Void) {
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: signOut,
                                            method: httpMethod.POST.rawValue,
                                            header: ["token": token],
                                            body: nil) else { return }
        
        session.dataTask(with: request) { (_, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse {
                completion(.success(self.getMessageFromCode(code: response.statusCode)))
            }
        }.resume()
    }
    
    // MARK: FETCHDATA
    func fetchData(completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: posts + feed,
                                            method: httpMethod.GET.rawValue,
                                            header: ["token":token],
                                            body: nil) else { return }
        
        session.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                do {
                    let users = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(users))
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // MARK: LIKE THIS POST
    func likeORunlikeTHisPost(isLike: Bool, postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        let data = ["postID":"\(postId)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])
        
        guard let request = generateRequest(for: posts + (isLike ? like : unlike),
                                            method: httpMethod.POST.rawValue,
                                            header: ["Content-Type":"application/json",
                                                     "token":token],
                                            body: jsonData) else { return }
        
        session.dataTask(with: request) { (_, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let response = response as? HTTPURLResponse {
                completion(.success(self.getMessageFromCode(code: response.statusCode)))
            }
            
        }.resume()
    }
    
    // MARK: GET posts/{postID}/likes
    func getLikedPosts(postID: String, completion: @escaping (Result<[User], Error>) -> Void) {
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: posts + "/\(postID)" + like + "s",
                                            method: httpMethod.GET.rawValue,
                                            header: ["token":token],
                                            body: nil) else { return }
        
        session.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                do {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    completion(.success(users))
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // MARK: GET users/{userID}/posts
    func getUsersPosts(userID: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: users + "/\(userID)" + "/" + posts,
                                            method: httpMethod.GET.rawValue,
                                            header: ["token":token],
                                            body: nil) else { return }
        
        session.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(posts))
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // MARK: return current user
    func getCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: currentUser,
                                            method: httpMethod.GET.rawValue,
                                            header: ["token":token],
                                            body: nil) else { return }
        
        session.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                do {
                    let users = try JSONDecoder().decode(User.self, from: data)
                    completion(.success(users))
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
        
    }
    // MARK: GET users/{userID}/followers/following
    func getFollowersORFollowing(isFolowers: Bool, userID: String, completion: @escaping (Result<[User], Error>) -> Void) {
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: users + "/\(userID)" + (isFolowers ? followers : following),
                                            method: httpMethod.GET.rawValue,
                                            header: ["token": token],
                                            body: nil) else { return }
        
        session.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let data = data {
                do {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    completion(.success(users))
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // MARK: GET users/{userID}
    func getUserByID(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: users + "/\(userID)",
            method: httpMethod.GET.rawValue,
            header: ["token":token],
            body: nil) else { return }
        
        session.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            if let data = data {
                do {
                    let users = try JSONDecoder().decode(User.self, from: data)
                    completion(.success(users))
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // MARK: POST users/follow unfollow
    func followORunfollow(wantFollow: Bool, userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        let data = ["userID":"\(userID)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: users + (wantFollow ? follow : unfollow),
                                            method: httpMethod.POST.rawValue,
                                            header: ["Content-Type":"application/json",
                                                     "token":token],
                                            body: jsonData) else { return }
        
        session.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    completion(.success(user))
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    // MARK: POST posts/create
    func createPost(image: UIImage, description: String, completion: @escaping (Result<String, Error>) -> Void ) {
        guard let imageData = image.jpegData(compressionQuality: 1)?.base64EncodedString() else { return }
        let data = ["image":"\(imageData)","description":"\(description)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])
        guard let token =  KeychainManger.shared.getToken(login: login) else { return }
        guard let request = generateRequest(for: posts + create,
                                            method: httpMethod.POST.rawValue,
                                            header: ["Content-Type":"application/json",
                                                     "token":token],
                                            body: jsonData) else { return }
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse {
                completion(.success(self.getMessageFromCode(code: response.statusCode)))
            }
            
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(Post.self, from: data)
                    print(user)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
        
        
    }
}

// MARK: Private func
extension NetworkManager {
    private func getMessageFromCode(code: Int) -> String {
        switch code {
        case 200:
            return "OK"
        case 400:
            return "Bad request"
        case 404:
            return "Not found"
        case 401:
            return "Unauthorized"
        case 406:
            return "Not acceptable"
        case 422:
            return "Unprocessable"
        default:
            if code == 500 { return "Call to LEGION"} else { return "Transfer error" }
        }
    }
    
    private func generateRequest(for action: String, method: String, header: [String: String], body: Data?) -> URLRequest? {
        
        guard let baseUrl = URL(string: hostPath) else {
            print("It will never heppend")
            return nil }
        let url = baseUrl.appendingPathComponent(action)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = header
        if let body = body {
            request.httpBody = body
        }
        return request
    }
}
