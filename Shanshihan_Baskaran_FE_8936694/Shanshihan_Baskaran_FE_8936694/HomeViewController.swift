import UIKit
import MapKit

class HomeViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var currentLocationMap: MKMapView!

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the CLLocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Check for location services authorization
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            currentLocationMap.showsUserLocation = true
        } else {
            // Handle the case where location services are not enabled
            print("Location services are not enabled.")
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last?.coordinate else {
            return
        }

        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        currentLocationMap.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = userLocation
        annotation.title = "Current Location"
        currentLocationMap.addAnnotation(annotation)

        locationManager.stopUpdatingLocation()
    }

    @IBAction func searchButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter City Name", message: nil, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "City Name"
        }

        let option1Action = UIAlertAction(title: "News", style: .default) { [weak self] (_) in
            if let cityName = alertController.textFields?.first?.text {
                self?.navigateToScreen(index: 1, cityName: cityName)
            }
        }

        let option2Action = UIAlertAction(title: "Direction", style: .default) { [weak self] (_) in
            if let cityName = alertController.textFields?.first?.text {
                self?.navigateToScreen(index: 2, cityName: cityName)
            }
        }

        let option3Action = UIAlertAction(title: "Weather", style: .default) { [weak self] (_) in
            if let cityName = alertController.textFields?.first?.text {
                self?.navigateToScreen(index: 3, cityName: cityName)
            }
        }

        alertController.addAction(option1Action)
        alertController.addAction(option2Action)
        alertController.addAction(option3Action)

        present(alertController, animated: true, completion: nil)
    }

    func navigateToScreen(index: Int, cityName: String) {
        if let tabBarController = self.tabBarController,
           let viewControllers = tabBarController.viewControllers,
           index < viewControllers.count {
            tabBarController.selectedIndex = index

            if let navController = tabBarController.viewControllers?[index] as? UINavigationController {
                if let topViewController = navController.topViewController as? NewsTableViewController {
                    topViewController.setCityName(cityName)
                }
            } else if let destinationVC = viewControllers[index] as? DirectionViewController {
                destinationVC.setCityName(cityName)
            } else if let destinationVC = viewControllers[index] as? WeatherViewController {
                destinationVC.setCityName(cityName)
            }
        }
    }
}
