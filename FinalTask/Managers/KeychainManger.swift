//
//  KeychainManger.swift
//  FinalTask
//
//  Created by Mykhailo Romanovskyi on 23.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

final class KeychainManger {
    
    static var shared = KeychainManger()
    private init() {}
    
    func getToken(login: String?) -> String? {
        
        var query = keychainQuery(account: login)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &queryResult)
        
        
        if status != noErr {
            return nil
        }
        
        guard let item = queryResult as? [String : AnyObject],
            let passwordData = item[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8) else { return nil }
        
        return password
    }
    
    func checkForToken(account: String) -> Bool {
        if getToken(login: account) != nil {
            
            return true
        } else { return false }
    }
    
    func saveToken(newToken: String, account: String?) -> Bool {
        let passwordData = newToken.data(using: .utf8)
        
        if getToken(login: account) != nil {
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = passwordData as AnyObject
            let query = keychainQuery(account: account)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            return status == noErr
        }
        
        var item = keychainQuery(account: account)
        item[kSecValueData as String] = passwordData as AnyObject
        let status = SecItemAdd(item as CFDictionary, nil)
        return status == noErr
    }
    
    func deleteToken() -> Bool {
        let item = keychainQuery()
        let status = SecItemDelete(item as CFDictionary)
        return status == noErr
    }
}

// MARK: Private
extension KeychainManger {
    
    private  func keychainQuery(account: String? = nil) -> [String : AnyObject] {
        let service = "myProject"
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        query[kSecAttrService as String] = service as AnyObject
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject
        }
        return query
    }
}

