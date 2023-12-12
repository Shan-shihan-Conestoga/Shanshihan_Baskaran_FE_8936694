//  Shanshihan_Baskaran_FE_8936694
//
//  Created by user233228 on 12/10/23.


import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!

    var cityName: String?

    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setCityName(_ cityName: String) {
        self.cityName = cityName
        geocodeCityAndCallAPI(cityName)
    }

    // MARK: - Navigation

    @IBAction func locationButton(_ sender: Any) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Which city weather you want?", message: "Please enter the name of the city", preferredStyle: .alert)

        // Add a text field to the alert controller
        alertController.addTextField { (cityTextField) in
            cityTextField.placeholder = "Enter city name"
        }

        // Create the OK action
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            // Retrieve the city name entered by the user
            if let inputcityname = alertController.textFields?[0].text {
                // Geocode the city name to get coordinates
                self?.geocodeCityAndCallAPI(inputcityname)
            }
        }

        // Add the action to the alert controller
        alertController.addAction(confirmAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }

    func getWeatherAPI(latatiduCord: String, longitudeCord: String) {
        guard let url = URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=\(latatiduCord)&lon=\(longitudeCord)&appid=3c9f7ef5c40f00e9188febcb2a8024ae&units=metric") else {
            return}
        let task = URLSession.shared.dataTask(with: url) { [self]
            data, response, error in
            /* print(data!)
             if let data = data, let string = String(data: data, encoding: .utf8){
             print(string)*/
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let jsonData = try jsonDecoder.decode(Weather.self, from: data)
                    print(jsonData.name)
                    print(jsonData.coord)
                    Task {@MainActor in
                        self.locationLabel.text = jsonData.name
                        self.weatherLabel.text = jsonData.weather[0].main
                        self.temperatureLabel.text = String(jsonData.main.temp) + " °"
                        self.humidityLabel.text = "Humidity : "+String(jsonData.main.humidity)+"%"
                        // convert m/h to km/h by multiplying 3.6
                        let windSpeedKMH = String(format: "%.f", jsonData.wind.speed * 3.6)
                        self.windLabel.text = "Wind : "+String(windSpeedKMH)+"km/h"
                        let iconCode = jsonData.weather[0].icon
                        print(iconCode)
                        let iconUrl = URL(string: "https://openweathermap.org/img/wn/\(iconCode).png")!
                        self.WeatherIcon(IconURL: iconUrl, weatherIconView: self.weatherImage)
                    }
                    
                } catch {
                    print("SOME ERROR")
                }
            }
        }
        task.resume()
    }
        //method to convert URL to Image
        func WeatherIcon(IconURL: URL, weatherIconView: UIImageView) {
                let task = URLSession.shared.dataTask(with: IconURL) { data, _, _ in
                    guard let data = data else { return }
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        weatherIconView.image = UIImage(data: data)
                    }
                }
                task.resume()
        }

    // Remaining methods...

    func geocodeCityAndCallAPI(_ cityName: String) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(cityName) { [weak self] (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                // Handle geocoding error if needed
            } else if let location = placemarks?.first?.location {
                // Use the obtained coordinates
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude

                // Do something with the latitude and longitude
                print("City: \(cityName), Latitude: \(latitude), Longitude: \(longitude)")

                // Call weather API with city coordinates
                self?.getWeatherAPI(latatiduCord: String(latitude), longitudeCord: String(longitude))
            }
        }
    }
}
