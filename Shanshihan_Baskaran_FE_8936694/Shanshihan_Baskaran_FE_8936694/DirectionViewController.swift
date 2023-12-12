//  Shanshihan_Baskaran_FE_8936694
//
//  Created by user233228 on 12/10/23.


import UIKit
import MapKit
import CoreLocation

class DirectionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var directionMapView: MKMapView!
    @IBOutlet weak var mapSlider: UISlider!
    
    var cityName: String?
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var destinationCity: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        directionMapView.delegate = self
        directionMapView.showsUserLocation = true
    }
    
    func setCityName(_ cityName: String) {
        self.cityName = cityName
        self.destinationCity = cityName
        self.geocodeCity(cityName)
    }
    
    @IBAction func carModeButton(_ sender: Any) {
        // Draw the route for car mode
        drawRoute(for: .automobile)
    }
    
    @IBAction func bikeModeButton(_ sender: Any) {
        // Draw the route for bike mode
        drawRoute(for: .walking)
    }
    
    @IBAction func walkModeButton(_ sender: Any) {
        // Draw the route for walking mode
        drawRoute(for: .walking)
    }
    
    @IBAction func mapSlider(_ sender: UISlider) {
        // The slider's value ranges from 0 to 1, adjust the zoom level as needed
        let span = MKCoordinateSpan(latitudeDelta: 0.01 + Double(sender.value) * 0.1, longitudeDelta: 0.01 + Double(sender.value) * 0.1)
        
        if let userLocation = userLocation {
            let region = MKCoordinateRegion(center: userLocation, span: span)
            directionMapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func locationButton(_ sender: Any) {
        // Retrieve the destination city name entered by the user
        let alertController = UIAlertController(title: "Where would you like to go?", message: "Enter your new destination here", preferredStyle: .alert)
        
        // Add a text field to the alert controller
        alertController.addTextField { (cityTextField) in
            cityTextField.placeholder = "Enter city name"
        }
        
        // Create the OK action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            if let cityName = alertController.textFields?[0].text {
                self?.destinationCity = cityName
                self?.geocodeCity(cityName)
            }
        }
        
        // Add the action to the alert controller
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func drawRoute(for transportType: MKDirectionsTransportType) {
        guard let userLocation = userLocation, let destinationCoordinate = getDestinationCoordinate() else {
            return
        }
        
        let sourcePlacemark = MKPlacemark(coordinate: userLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = transportType
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [weak self] (response, error) in
            guard let response = response, error == nil else {
                print("Error calculating directions: \(error?.localizedDescription ?? "")")
                return
            }
            
            let route = response.routes[0]
            self?.directionMapView.removeOverlays(self?.directionMapView.overlays ?? [])  // Remove existing overlays
            self?.directionMapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self?.directionMapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    private func getDestinationCoordinate() -> CLLocationCoordinate2D? {
        // Use the stored destination city name
        return geocodeCity(destinationCity)
    }
    
    func geocodeCity(_ cityName: String?) -> CLLocationCoordinate2D? {
        guard let cityName = cityName else {
            return nil
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { [weak self] (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("Location not found")
                return
            }
            
            // Add a pin for the destination city
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.coordinate = location.coordinate
            destinationAnnotation.title = cityName
            self?.directionMapView.addAnnotation(destinationAnnotation)
            
            // Draw the polyline from current location to the destination city
            if let userLocation = self?.userLocation {
                self?.showRouteOnMap(userLocation, destination: location.coordinate)
            }
        }
        
        return nil  // The actual coordinate will be obtained in the completion block
    }
    
    func showRouteOnMap(_ source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { [weak self] (response, error) in
            guard let response = response, error == nil else {
                print("Error calculating directions: \(error?.localizedDescription ?? "")")
                return
            }
            
            let route = response.routes[0]
            self?.directionMapView.removeOverlays(self?.directionMapView.overlays ?? [])  // Remove existing overlays
            self?.directionMapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self?.directionMapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        userLocation = location
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
}
