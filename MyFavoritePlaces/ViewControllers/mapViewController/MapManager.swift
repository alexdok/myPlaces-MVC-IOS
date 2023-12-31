//
//  MapManager.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 02.06.2023.
//

import UIKit
import MapKit

final class MapManager {
    
    let alertBuilder = AlertBuilderImpl()
    let locationManager = CLLocationManager()
    var textTime = ""
    var textPath = ""
    let regionInMeters: Double = 3000
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []

    
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
                let alertModel = AlertModel(title: "Your Location Services are Disabled", message: "To enable it go: Setting -> Privacy -> Location Services and turn on")
                self.alertBuilder.showInfoAlert(with: alertModel)
            }
        }
    }
    
    func locationManagerDidChangeAuthorization( manager: CLLocationManager, identifierSegue: String, mapView: MKMapView ) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let alertModel = AlertModel(title: "Your Location Services are Disabled", message: "To enable it go: Setting -> Privacy -> Location Services and turn on")
                self.alertBuilder.showInfoAlert(with: alertModel)
            }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let alertModel = AlertModel(title: "Your Location Services are Disabled", message: "To enable it go: Setting -> Privacy -> Location Services and turn on")
                self.alertBuilder.showInfoAlert(with: alertModel)
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
    
    func getDirections(mapView: MKMapView, previousLocation: (CLLocation) -> Void) {
        guard let location = locationManager.location?.coordinate else {
            let alertModel = AlertModel(title: "Error", message: "Current location is not found")
            alertBuilder.showInfoAlert(with: alertModel)
            return
        }
        guard let request = createDiractionsRequest(coordinate: location) else {
            let alertModel = AlertModel(title: "Error", message: "Current location is not found")
            alertBuilder.showInfoAlert(with: alertModel)
            return
        }
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        directionsCalculate(directions: directions, mapView: mapView)
    }
    
    private func directionsCalculate(directions: MKDirections, mapView: MKMapView) {
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                let alertModel = AlertModel(title: "ERROR", message: "Directions is not available")
                self.alertBuilder.showInfoAlert(with: alertModel)
                return
            }
            self.showRoutesAndInfoOnMap(routes: response.routes, mapView: mapView)
        }
    }
    
    private func showRoutesAndInfoOnMap(routes: [MKRoute], mapView: MKMapView) {
        for route in routes {
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            let distance = String(format: "%.1f", route.distance / 1000)
            let timeInterval = route.expectedTravelTime
            textPath = "distance: \(distance) km"
            let time = TimeConverter.shared.convertSecondsToHMS(seconds: Int(timeInterval))
            textTime = "travel time: \(time)"
            print("расстояние \(distance) km")
            print("время в пути \(timeInterval) sec")
        }
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
}
