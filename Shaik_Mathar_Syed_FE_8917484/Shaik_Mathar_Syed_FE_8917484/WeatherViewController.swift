//
//  WeatherViewController.swift
//  Shaik_Mathar_Syed_FE_8917484
//
//  Created by Shaik Mathar Syed on 11/12/23.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    let apiKey = "91ae61a7418549d33a28664b65bb7fd7"

    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageLabel: UIImageView!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    var cityName: String?

    var selectedCity: String?

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // Create a LocationManager
    let userLocationManager = CLLocationManager()

    // Function to Download the Image from the API response
    func getClimateImage(imageURL: URL, weatherImageView: UIImageView) {
        let task = URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async { // Make sure you're on the main thread here
                weatherImageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if CLLocationManager.locationServicesEnabled() {
            userLocationManager.delegate = self
            userLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            userLocationManager.requestWhenInUseAuthorization()
            userLocationManager.startUpdatingLocation()
            userLocationManager.distanceFilter = 8
        }
    }

    // Function call and show the response from the API
    func getWeatherApi(city: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)")
        else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let jsonData = try jsonDecoder.decode(Weather.self, from: data)

                    let imageURL = URL(string: "https://openweathermap.org/img/wn/" + jsonData.weather[0].icon + "@2x.png")
                        Task { @MainActor in
                            self.locationLabel.text = jsonData.name
                            self.weatherDescriptionLabel.text = String(jsonData.weather[0].main)
                            self.temperatureLabel.text = String(format: "%.1f", jsonData.main.temp) + " º"
                            self.humidityLabel.text = "Humidity: " + String(jsonData.main.humidity) + "%"
                            self.windLabel.text = "Wind: " + String(format: "%.2f", jsonData.wind.speed*3.6) + " km/h"
                            self.getClimateImage(imageURL: imageURL!, weatherImageView: self.weatherImageLabel)
                        }
                    } catch {
                        print("Error")
                    }
                }
            }
            task.resume()
        }

    @IBAction func locationButton(_ sender: Any) {
        showChangeLocationAlert()
    }

    func showChangeLocationAlert(){
        let alertController = UIAlertController(
                title: "Where would you want the weather from?",
                message: "Enter your new location here",
                preferredStyle: .alert
            )

            alertController.addTextField { textField in
                textField.placeholder = "Enter city name"
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let changeAction = UIAlertAction(title: "Change", style: .default) { _ in
                if let cityName = alertController.textFields?.first?.text {
                    self.selectedCity = cityName
                    self.getWeatherApi(city: cityName)
                }
            }

            alertController.addAction(cancelAction)
            alertController.addAction(changeAction)

        present(alertController, animated: true, completion: nil)
    }

    func convertCityToCoordinatesAndFetchWeather(_ cityName: String) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(cityName) { [weak self] (placemarks, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                // Handle geocoding error if needed
            } else if let location = placemarks?.first?.location {
                // Use the obtained coordinates
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude

                // Call weather API with city coordinates
                self?.getWeatherApi(city: cityName)

                // Do something with the latitude and longitude
                print("City: \(cityName), Latitude: \(lat), Longitude: \(lon)")
            }
        }
    }

    func setCityName(_ cityName: String) {
        self.cityName = cityName
        convertCityToCoordinatesAndFetchWeather(cityName)
    }

    // Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }

}
