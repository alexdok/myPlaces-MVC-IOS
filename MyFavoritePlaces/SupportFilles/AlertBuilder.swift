//
//  AlertBuilder.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 21.08.2023.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
}

protocol AlertImagePickerBuilder {
    func createImagePickerAlert(imagePickerAction: @escaping (UIImagePickerController.SourceType) -> Void) -> UIAlertController
}

protocol AlertDeleteBuilder {
    func createAlertDelete(with model: AlertModel, deletePlace: @escaping () -> Void) -> UIAlertController
}

protocol AlertInfoBuilder {
    func showInfoAlert(with model: AlertModel)
}

final class AlertBuilderImpl: AlertDeleteBuilder, AlertImagePickerBuilder, AlertInfoBuilder {
    
    func showInfoAlert(with model: AlertModel) {
        
        let alertController = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        NotificationCenter.default.post(name: NSNotification.Name("ShowAlertNotification"), object: nil, userInfo: ["alertController": alertController])
        
    }
    
    func createImagePickerAlert(imagePickerAction: @escaping (UIImagePickerController.SourceType) -> Void) -> UIAlertController {
        let cameraIcon = #imageLiteral(resourceName: "photo")
        let galleryIcon = #imageLiteral(resourceName: "gallery")
        
        let alert = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
    
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            imagePickerAction(.camera)
        }
        cameraAction.setValue(cameraIcon, forKey: "image")
        cameraAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            imagePickerAction(.photoLibrary)
        }
        photoLibraryAction.setValue(galleryIcon, forKey: "image")
        photoLibraryAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(cancelAction)
        
        return alert
    }
    
    func createAlertDelete(with model: AlertModel, deletePlace: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "DELETE", style: .default) { _ in
            deletePlace()
        }
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addAction(delete)
        alert.addAction(cancelAction)
        
        return alert
    }
}


