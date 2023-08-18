////
////  NewPlaceViewControllerViewModel.swift
////  MyFavoritePlaces
////
////  Created by алексей ганзицкий on 18.08.2023.
////
//
//import Foundation
//
//class NewPlaceViewControllerViewModel {
//    
//    var currentPlace = Place()
//    
//    func savePlace(placce: Place) {
// 
//        if currentPlace != nil {
//            try! realm.write({
//                currentPlace?.name = placce.name
//                currentPlace?.location = placce.location
//                currentPlace?.type = placce.type
//                currentPlace?.imageData = placce.imageData
//                currentPlace?.rating = placce.rating
//            })
//        } else {
//            StorageManager.saveObject(newPlace)
//        }
//    }
//}
