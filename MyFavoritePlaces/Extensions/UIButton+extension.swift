//
//  UIButton+extension.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 15.08.2023.
//

import UIKit

extension UIButton {
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 3
      //  layer.shadowPath = UIBezierPath(rect: bounds).cgPath // для закруглённых углов
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width/2).cgPath // для круга
        layer.shouldRasterize = true
    }
}
