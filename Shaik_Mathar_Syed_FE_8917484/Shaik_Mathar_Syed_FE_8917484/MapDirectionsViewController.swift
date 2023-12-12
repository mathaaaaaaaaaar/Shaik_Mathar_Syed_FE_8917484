//
//  MapDirectionsViewController.swift
//  Shaik_Mathar_Syed_FE_8917484
//
//  Created by Shaik Mathar Syed on 11/12/23.
//

import UIKit
import MapKit
import CoreLocation

class MapDirectionsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var destination: String?
    var cityName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        mapView.delegate = self
        mapView.showsUserLocation = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func walkButton(_ sender: Any) {
        plotRoute(for: .walking)
    }
    @IBAction func bikeButton(_ sender: Any) {
        plotRoute(for: .walking)
    }
    @IBAction func carButton(_ sender: Any) {
        plotRoute(for: .automobile)
    }
    @IBAction func mapZoomSlider(_ sender: UISlider) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01 + Double(sender.value) * 0.1, longitudeDelta: 0.01 + Double(sender.value) * 0.1)

        if let currentLocation = currentLocation {
            let region = MKCoordinateRegion(center: currentLocation, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    @IBAction func locationButton(_ sender: Any) {
        // Retrieve the target city name entered by the user
        let alertCtrl = UIAlertController(title: "Where would you like to go?", message: "Enter your new destination here", preferredStyle: .alert)

        // Add a text field to the alert controller
        alertCtrl.addTextField { (cityTextField) in
            cityTextField.placeholder = "Enter city name"
        }

        // Create the OK action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            if let cityName = alertCtrl.textFields?[0].text {
                self?.destination = cityName
                self?.convertCityToCoordinates(cityName)
            }
        }

        // Add the action to the alert controller
        alertCtrl.addAction(cancelAction)
        alertCtrl.addAction(confirmAction)

        // Present the alert controller
        self.present(alertCtrl, animated: true, completion: nil)
    }
    
    private func plotRoute(for mode: MKDirectionsTransportType) {
        guard let currentLocation = currentLocation, let targetCoordinate = fetchTargetCoordinate() else {
            return
        }

        let originPlacemark = MKPlacemark(coordinate: currentLocation)
        let targetPlacemark = MKPlacemark(coordinate: targetCoordinate)

        let originMapItem = MKMapItem(placemark: originPlacemark)
        let targetMapItem = MKMapItem(placemark: targetPlacemark)

        let directionsRequest = MKDirections.Request()
        directionsRequest.source = originMapItem
        directionsRequest.destination = targetMapItem
        directionsRequest.transportType = mode

        let directions = MKDirections(request: directionsRequest)
        directions.calculate { [weak self] (response, error) in
            guard let routeResponse = response, error == nil else {
                print("Error calculating directions: \(error?.localizedDescription ?? "")")
                return
            }

            let route = routeResponse.routes[0]
            self?.mapView.removeOverlays(self?.mapView.overlays ?? [])  // Remove existing overlays
            self?.mapView.addOverlay(route.polyline, level: .aboveRoads)

            let boundingRect = route.polyline.boundingMapRect
            self?.mapView.setRegion(MKCoordinateRegion(boundingRect), animated: true)
        }
    }

    private func fetchTargetCoordinate() -> CLLocationCoordinate2D? {
        // Use the stored target city name
        return convertCityToCoordinates(destination)
    }

    func convertCityToCoordinates(_ cityName: String?) -> CLLocationCoordinate2D? {
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

            // Add a pin for the target city
            let targetAnnotation = MKPointAnnotation()
            targetAnnotation.coordinate = location.coordinate
            targetAnnotation.title = cityName
            self?.mapView.addAnnotation(targetAnnotation)

            // Draw the polyline from current location to the target city
            if let currentLocation = self?.currentLocation {
                self?.displayRouteOnMap(currentLocation, destination: location.coordinate)
            }
        }

        return nil  // The actual coordinate will be obtained in the completion block
    }

    func displayRouteOnMap(_ origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let originPlacemark = MKPlacemark(coordinate: origin)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let originMapItem = MKMapItem(placemark: originPlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let directionsRequest = MKDirections.Request()
        directionsRequest.source = originMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.transportType = .automobile

        let directions = MKDirections(request: directionsRequest)
        directions.calculate { [weak self] (routeResponse, error) in
            guard let routeResponse = routeResponse, error == nil else {
                print("Error calculating directions: \(error?.localizedDescription ?? "")")
                return
            }

            let route = routeResponse.routes[0]
            self?.mapView.removeOverlays(self?.mapView.overlays ?? [])  // Remove existing overlays
            self?.mapView.addOverlay(route.polyline, level: .aboveRoads)

            let boundingRect = route.polyline.boundingMapRect
            self?.mapView.setRegion(MKCoordinateRegion(boundingRect), animated: true)
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        currentLocation = location
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }

    func setCityName(_ cityName: String) {
        self.cityName = cityName
        self.destination = cityName
        self.convertCityToCoordinates(cityName)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
