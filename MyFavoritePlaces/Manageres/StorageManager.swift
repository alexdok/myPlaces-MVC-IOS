//
//  StorageManager.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 03.03.2023.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func delObject(_ place: Place) {
        try! realm.write({
            realm.delete(place)
        })
    }
}
