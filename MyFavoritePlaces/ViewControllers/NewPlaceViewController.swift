//
//  NewPlaceViewController.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 21.02.2023.
//

import UIKit
import Cosmos

enum Segues: String {
    case showPlaceLocation = "showPlaceLocation"
    case showUserLocation = "showUserLocation"
}

final class NewPlaceViewController: UITableViewController {
    
    let alertBuilder = AlertBuilderImpl()
    var imageIsChanged = false
    var currentPlace: Place?
    var currentRating = 0.0
//    let picker = UIDatePicker()
    
    @IBOutlet weak var cosmosRatingView: CosmosView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var placeType: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        setupEditScreen()
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setCosmosView()
        mapButton.dropShadow()
    }
    
    //MARK: navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mapVC = segue.destination as? MapViewController else { return }
        mapVC.place.name = placeName.text ?? ""
        mapVC.place.location = placeLocation.text ?? ""
        mapVC.place.type = placeType.text ?? ""
        mapVC.place.imageData = placeImage.image?.pngData()
        mapVC.mapViewControllerDelegate = self
        switch segue.identifier {
        case Segues.showPlaceLocation.rawValue :
            mapVC.identifierSegue = Segues.showPlaceLocation.rawValue
        case Segues.showUserLocation.rawValue :
            mapVC.identifierSegue = Segues.showUserLocation.rawValue
        default : break
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    func setCosmosView() {
        cosmosRatingView.settings.fillMode = .full
        cosmosRatingView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
    }
    
    func savePlace() {
        guard let namePlace = placeName.text else { return }
        let image = imageIsChanged ? placeImage.image : UIImage(named: "noImage")
        let imageData = image?.pngData()
        let newPlace = Place(name: namePlace, location: placeLocation.text, type: placeType.text, imageData: imageData, rating: cosmosRatingView.rating)
        if currentPlace != nil {
            try! realm.write({
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            })
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFit
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            cosmosRatingView.rating = currentPlace?.rating ?? 0
        }
    }
    
    private func createAlertController() {
        let imagePickerAlert = alertBuilder.createImagePickerAlert { [weak self] sourceType in
            self?.chooseImagePicker(source: sourceType)
        }
        present(imagePickerAlert, animated: true, completion: nil)
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    //MARK: table View delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            createAlertController()
        } else {
            view.endEditing(true)
        }
    }
}

