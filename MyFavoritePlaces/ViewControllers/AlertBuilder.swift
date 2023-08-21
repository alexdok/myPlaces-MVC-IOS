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

protocol AlertBuilder {
    func createAlert(with model: AlertModel, deletePlace: @escaping () -> Void) -> UIAlertController
}

final class AlertBuilderImpl: AlertBuilder {
    func createAlert(with model: AlertModel, deletePlace: @escaping () -> Void) -> UIAlertController {
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


