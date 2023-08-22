//
//  MainViewControllerViewModel.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 14.08.2023.
//

import Foundation


class MainViewModel {

    let dataProvider = DataProviderImpl()
    var data = [Place]()
    
    func fetchData(metod: Metods, filter: Filters) -> [Place] {
        data = dataProvider.provideCurrentPlaces(metod: metod, filter: filter)
        return data
    }
    
    func fetchData(metod: Metods) -> [Place] {
        data = dataProvider.provideCurrentPlaces(metod: metod, filter: .date)
        return data
    }
    
    func delPlace(place: Place) -> [Place] {
        data = dataProvider.removePlace(place: place)
        return data
    }
    
    func filterPlaces(filterText: String) -> [Place] {
        data = dataProvider.filterPlaces(serchText: filterText)
        return data
    }
}
