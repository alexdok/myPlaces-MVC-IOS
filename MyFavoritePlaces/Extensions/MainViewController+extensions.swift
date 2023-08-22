//
//  MainViewController+extensions.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 02.06.2023.
//

import Foundation
import RealmSwift

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PlacesTableViewCell else { return UITableViewCell()}
        let place = places[indexPath.row]
        cell.name.text = place.name
        cell.location.text = place.location
        cell.type.text = place.type
        if let data = place.imageData {
            cell.imageOfPlace.image = UIImage(data: data)
        }
        cell.cosmosView.rating = place.rating
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertModel = AlertModel(title: "are you shure?", message: "are you shure DELETE this place")
            let alert = alertBuilder.createAlertDelete(with: alertModel) {
                self.delPlace(indexPath: indexPath)
            }
            present(alert, animated: true)
        }
    }
    
    func delPlace(indexPath: IndexPath) {
        let place = places.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.places = self.mainViewModel.delPlace(place: place)
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" || searchController.searchBar.text == " "{
            places = mainViewModel.fetchData(metod: .currentPlaces)
            tableView.reloadData()
            return
        } else {
            filterContentForSearchText(searchController.searchBar.text ?? "")
        }
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        places = mainViewModel.filterPlaces(filterText: searchText)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
        }
    }
}
