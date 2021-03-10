//
//  MyExtension.swift
//  Course2FinalTask
//
//  Created by Mykhailo Romanovskyi on 06.03.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat? = 0,
                paddingBottom: CGFloat? = 0,
                paddingLeft: CGFloat? = 0,
                paddingRight: CGFloat? = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop!).isActive = true
        }
        if let left = left {
            leadingAnchor.constraint(equalTo: left, constant: paddingLeft!).isActive = true
        }
        if let right = right {
            trailingAnchor.constraint(equalTo: right, constant: -paddingRight!).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant:  -paddingBottom!).isActive = true
        }
    }
    
    func anchorSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func anchorCenterXY(centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }
}

