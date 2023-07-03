//
//  MapViewController+extensions.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 02.06.2023.
//

import UIKit
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as? MKPolyline ?? MKPolyline())
        render.strokeColor = .blue
        return render
    }
    
    private func animationPin(alpha: Double, shiftY: Int) {
        mapPin.alpha = alpha
        mapPin.tintColor = .blue
        mapPin.bounds.origin.y = CGFloat(shiftY)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        animationPin(alpha: 1, shiftY: -40)
    }
    
    private func getPlaceMark(geocoder: CLGeocoder) {
        let center = mapManager.getCenterLocation(for: mapView)
        geocoder.reverseGeocodeLocation(center) { [weak self] (placeMarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placeMarks = placeMarks else { return }
            let placemark = placeMarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self?.currentPlaceLabel.text = "\(streetName ?? ""), \(buildNumber ?? "")"
                } else if streetName != nil {
                    self?.currentPlaceLabel.text = "\(streetName ?? "")"
                } else {
                    self?.currentPlaceLabel.text = "place not found"
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        animationPin(alpha: 0.6, shiftY: -10)
        let geocoder = CLGeocoder()
        if identifierSegue == Segues.showPlaceLocation.rawValue && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        geocoder.cancelGeocode()
        getPlaceMark(geocoder: geocoder)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        if  annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.locationManagerDidChangeAuthorization(manager: mapManager.locationManager, identifierSegue: identifierSegue, mapView: mapView)
    }
}
