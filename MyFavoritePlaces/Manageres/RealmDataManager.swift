//
//  RealmDataManager.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 15.08.2023.
//

import RealmSwift

final class RealmDatamanager {
    private let realm = try! Realm()
    
    var places: Results<Place>!
    var filteredPlaces: Results<Place>!
    var ascendingSorting = true
    
    init() {
        places = realm.objects(Place.self)
    }
    
    func sortPlaces(byKeyPath keyPath: String) {
        places = places.sorted(byKeyPath: keyPath, ascending: ascendingSorting)
    }
    
    func deletePlace(place: Place) {
        StorageManager.delObject(place)
    }
    
    func filterPlaces(for searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
    }
}
