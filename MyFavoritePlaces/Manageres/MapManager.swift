//
//  MapManager.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 02.06.2023.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    var textTime = ""
    var textPath = ""
    let regionInMeters: Double = 3000
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var showAlertClosure: ((_ title: String, _ message: String) -> Void)?

    
    func setupPlacemark(place: Place, mapView: MKMapView) {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] (placeMark, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placeMarks = placeMark else { return }
            let placeMark = placeMarks.first
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placeMarkLocation = placeMark?.location else { return }
            self?.placeCoordinate = placeMarkLocation.coordinate
            annotation.coordinate = placeMarkLocation.coordinate
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocationService(mapView: MKMapView, segueIdentifier: String, closure: () -> Void ) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManagerDidChangeAuthorization(manager: locationManager, identifierSegue: segueIdentifier, mapView: mapView)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your Location Services are Disabled",
                               message: "To enable it go: Setting -> Privacy -> Location Services and turn on")
            }
        }
    }
    
    func locationManagerDidChangeAuthorization( manager: CLLocationManager, identifierSegue: String, mapView: MKMapView ) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location is not Availeble",
                               message: "To give permission Go to: Setting -> MyFavoritePlaces -> Location")
            }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location is not Availeble",
                               message: "To give permission Go to: Setting -> MyFavoritePlaces -> Location")
            }
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if identifierSegue == Segues.showUserLocation.rawValue {
                showUserLocation(mapView: mapView)
            }
            break
        @unknown default:
            print("NEW CASE")
            break
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        guard let request = createDiractionsRequest(coordinate: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "ERROR", message: "Directions is not available")
                return
            }
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                self.textPath = "distance: \(distance) km"
                let time = self.convertSecondsToHMS(seconds: Int(timeInterval))
                self.textTime = "travel time: \(time)"
                print("расстояние \(distance) km")
                print("время в пути \(timeInterval) sec")
            }
        }
    }
    
   private func convertSecondsToHMS(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        return String(format: "%2dh %2dm %2ds", hours, minutes, seconds)
    }
    
    func createDiractionsRequest(coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let finishLocation = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: finishLocation)
        request.transportType = .walking
        return request
    }
    
    func startTrackinguserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation:CLLocation) -> Void) {
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)
    }
    
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        NotificationCenter.default.post(name: NSNotification.Name("ShowAlertNotification"), object: nil, userInfo: ["alertController": alertController])
    }
}
