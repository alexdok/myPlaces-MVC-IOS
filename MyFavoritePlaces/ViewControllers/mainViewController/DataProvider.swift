//
//  DataProvider.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 15.08.2023.
//
import Foundation

protocol DataProvider {
    func provideCurrentPlaces(metod: Metods, filter: Filters) -> [Place]
    func removePlace(indexPath: IndexPath) -> [Place]
    func filterPlaces(serchText: String) -> [Place]
    func realmDataToPlaces() -> [Place]
}

enum Metods {
    case currentPlaces
    case filtredPlaces
}

enum Filters: String {
    case name = "name"
    case date = "date"
}

class DataProviderImpl: DataProvider {
    
    var realmDataManager = RealmDatamanager()
    
    func provideCurrentPlaces(metod: Metods, filter: Filters) -> [Place] {
        var places = [Place]()
        
        switch metod {
        case .currentPlaces:
            places = realmDataToPlaces()
            return places
        case .filtredPlaces:
            realmDataManager.sortPlaces(byKeyPath: filter.rawValue)
            places = realmDataToPlaces()
            return places
        }
    }
    
    func removePlace(indexPath: IndexPath) -> [Place] {
        var places = [Place]()
        realmDataManager.deletePlace(at: indexPath)
        places = realmDataToPlaces()
        return places
    }
    
    func filterPlaces(serchText: String) -> [Place] {
        var filterPlaces = [Place]()
        realmDataManager.filterPlaces(for: serchText)
        realmDataManager.filteredPlaces.forEach { place in
            filterPlaces.append(place)
        }
        return filterPlaces
    }
    
    func realmDataToPlaces() -> [Place] {
        var places = [Place]()
        realmDataManager.places.forEach { place in
            places.append(place)
        }
        return places
    }
    
}
