//
//  Alert.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 17.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    class func showAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Unknown error", message: "Something went wrong, you might be oflline, try to login", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
    class func errorAlertFromServer(vc: UIViewController, message: String ) {
        
        let alert = UIAlertController(title: "Server response", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
    class func offLineAlert(vc: UIViewController) {
        
        let alert = UIAlertController(title: "Error", message: "You are OFFLINE. Only can look no change", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
}
