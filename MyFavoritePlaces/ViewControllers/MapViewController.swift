//
//  MapViewController.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 17.05.2023.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let mapManager = MapManager()
    let annotationIdentifier = "annotationIdentifier"
    var identifierSegue = ""
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackinguserLocation(for: mapView, and: previousLocation) { [ weak self ] currentLocation in
                guard let self = self else { return }
                self.previousLocation = currentLocation
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet weak var distanceDirections: UILabel!
    @IBOutlet weak var timeDirections: UILabel!
    @IBOutlet weak var buttonGetDirections: UIButton!
    @IBOutlet weak var findMeButton: CustomeButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPin: UIImageView!
    @IBOutlet weak var currentPlaceLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func centerViewInUserLocation(_ sender: UIButton) {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isRotateEnabled = false
        setupMapView()
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert(notification:)), name: NSNotification.Name("ShowAlertNotification"), object: nil)
    }
    
    @IBAction func closeVC(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        mapViewControllerDelegate?.getAddress(currentPlaceLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func getDirectionsButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.buttonGetDirections.alpha = 0.5
        } completion: { _ in
            self.animateLabels()
            self.buttonGetDirections.alpha = 1
            self.mapManager.getDirections(mapView: self.mapView) { (location) in
                self.previousLocation = location
            }
        }
    }
    
    @objc private func showAlert(notification: Notification) {
         guard let alertController = notification.userInfo?["alertController"] as? UIAlertController else { return }
         present(alertController, animated: true)
     }
    
    private func animateLabels() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            UIView.animate(withDuration: 0.3) {
                self.distanceDirections.alpha = 1
                self.timeDirections.alpha = 1
            } completion: { _ in
                self.distanceDirections.text = self.mapManager.textPath
                self.timeDirections.text = self.mapManager.textTime
            }
        }
    }
    
    private func setupMapView() {
        distanceDirections.alpha = 0
        timeDirections.alpha = 0
        if identifierSegue == Segues.showUserLocation.rawValue {
            buttonGetDirections.isHidden = true
        }
        mapManager.checkLocationService(mapView: mapView, segueIdentifier: identifierSegue) {
            mapManager.locationManager.delegate = self
        }
        if identifierSegue == Segues.showPlaceLocation.rawValue {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPin.isHidden = true
            doneButton.isHidden = true
            currentPlaceLabel.isHidden = true
        }
    }
}
