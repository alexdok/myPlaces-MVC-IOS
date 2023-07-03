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
        if isFiltering {
            return filteredPlaces.count
        } else {
            return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PlacesTableViewCell else { return UITableViewCell()}
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
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
            let place = places[indexPath.row]
            delAlertController(place: place, indexPath: indexPath)
        }
    }
    
    private func delAlertController(place: Place, indexPath: IndexPath) {
        let confirmeAlertController = UIAlertController(title: nil, message: "are you shure DELETE this place", preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "DELETE", style: .destructive) { _ in
            StorageManager.delObject(place)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel)
        confirmeAlertController.addAction(ok)
        confirmeAlertController.addAction(cancel)
        present(confirmeAlertController, animated: true)
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}
