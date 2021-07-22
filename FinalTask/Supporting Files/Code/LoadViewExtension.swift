//
//  LoadView.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 17.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

fileprivate var aView: UIView?

extension UIViewController {
    func startWaitingIndicator() {
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let activeIndicator = UIActivityIndicatorView(style: .white)
        activeIndicator.center = aView!.center
        activeIndicator.startAnimating()
        
        aView?.addSubview(activeIndicator)
        self.view.addSubview(aView!)
    }
    
    func stopWaitingIndicator() {
        aView?.removeFromSuperview()
        aView = nil
    }
}
