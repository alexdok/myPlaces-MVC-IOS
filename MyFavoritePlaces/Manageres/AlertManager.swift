//
//  AlertMabager.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 18.08.2023.
//


import UIKit

protocol AlertPresentable {
    func presentAlert(indexPath: IndexPath) -> Bool
}

extension AlertPresentable where Self: UIViewController {
  
    
    func presentAlert(indexPath: IndexPath) -> Bool {
        var okOrCcancel = false
            let confirmeAlertController = UIAlertController(title: nil, message: "are you shure DELETE this place", preferredStyle: .actionSheet)
            
            let ok = UIAlertAction(title: "DELETE", style: .destructive) { _ in
                okOrCcancel = true
            }
            
            let cancel = UIAlertAction(title: "cancel", style: .cancel)
        
            confirmeAlertController.addAction(ok)
            confirmeAlertController.addAction(cancel)
            present(confirmeAlertController, animated: true)
        return okOrCcancel
        
    }
}
