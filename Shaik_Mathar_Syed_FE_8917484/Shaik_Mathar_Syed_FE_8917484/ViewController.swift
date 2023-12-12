//
//  ViewController.swift
//  Shaik_Mathar_Syed_FE_8917484
//
//  Created by Shaik Mathar Syed on 11/12/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationMgr = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Set up the CLLocationManager
        locationMgr.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest

        // Check for location services authorization
        if CLLocationManager.locationServicesEnabled() {
            locationMgr.requestWhenInUseAuthorization()
            locationMgr.startUpdatingLocation()
        } else {
            // Handle the case where location services are not enabled
            print("Location services are not enabled.")
        }
    }

    @IBAction func startButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter City Name", message: nil, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "City Name"
        }

        let newsAction = UIAlertAction(title: "News", style: .default) { [weak self] (_) in
            if let cityName = alertController.textFields?.first?.text {
                self?.navigateToScreen(index: 1, cityName: cityName)
            }
        }

        let mapsAction = UIAlertAction(title: "Direction", style: .default) { [weak self] (_) in
            if let cityName = alertController.textFields?.first?.text {
                self?.navigateToScreen(index: 2, cityName: cityName)
            }
        }

        let weatherAction = UIAlertAction(title: "Weather", style: .default) { [weak self] (_) in
            if let cityName = alertController.textFields?.first?.text {
                self?.navigateToScreen(index: 3, cityName: cityName)
            }
        }

        alertController.addAction(newsAction)
        alertController.addAction(mapsAction)
        alertController.addAction(weatherAction)

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
            } else if let destinationVC = viewControllers[index] as? MapDirectionsViewController {
                destinationVC.setCityName(cityName)
            } else if let destinationVC = viewControllers[index] as? WeatherViewController {
                destinationVC.setCityName(cityName)
            }
        }
    }

}

