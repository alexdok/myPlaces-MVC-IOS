import XCTest
import MapKit

@testable import MyFavoritePlaces

class MapManagerTests: XCTestCase {
    
    var capturedAlertTitle: String?
    var capturedAlertMessage: String?
    var mapManager: MapManager!
    var mapView: MKMapView!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mapManager = MapManager()
        mapView = MKMapView()
    }

    override func tearDownWithError() throws {
        mapManager = nil
        mapView = nil
        try super.tearDownWithError()
    }
    
    func testSetupPlacemark() {
        let place = Place(name: "test name", location: "voronezh", type: nil, imageData: nil, rating: 1)
        
        let expectation = self.expectation(description: "Annotation added")
        
        mapManager.setupPlacemark(place: place, mapView: mapView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.mapView.annotations.count, 1, "Annotation should be added to the map view")
            
            if let annotation = self.mapView.annotations.first {
                XCTAssertEqual(annotation.title, place.name, "Annotation title should match place name")
                XCTAssertEqual(annotation.subtitle, place.type, "Annotation subtitle should match place type")
            } else {
                XCTFail("No annotations found on the map view")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testCheckLocationServiceEnabled() {
        mapManager.locationManager.delegate = mapManager as? any CLLocationManagerDelegate
        
        mapManager.checkLocationService(mapView: mapView, segueIdentifier: "TestSegue") {
            // Closure should be executed when location services are enabled
        }
        
        XCTAssertTrue(mapView.showsUserLocation, "User location should be shown on the map view")
        XCTAssertEqual(mapManager.locationManager.authorizationStatus, .authorizedWhenInUse, "Location manager authorization status should be authorizedWhenInUse")
    }

    func testShowUserLocation() {
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        mapManager.showUserLocation(mapView: mapView)
        
        let expectedLatitude = location.coordinate.latitude
        let expectedLongitude = location.coordinate.longitude
        
        XCTAssertEqual(mapView.region.center.latitude, expectedLatitude, accuracy: 1, "Map view region center latitude should match expected region center latitude")
        XCTAssertEqual(mapView.region.center.longitude, expectedLongitude, accuracy: 1, "Map view region center longitude should match expected region center longitude")
    }

    
    // Add more tests for the remaining methods
    
}
