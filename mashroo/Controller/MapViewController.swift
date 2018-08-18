//
//  ViewController.swift
//  mashroo
//
//  Created by Hassan El Desouky on 2/21/18.
//  Copyright © 2018 Hassan El Desouky. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON
import MaterialComponents.MaterialAppBar
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialCollections

class MapViewController: UIViewController {
    
    //MARK: - Oulets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: - Properties
    var mashroos = [Mashroos]()
    var locationManager = CLLocationManager()
    private let regionRadius: CLLocationDistance = 1000
    var currentPlacemark: CLPlacemark?
    //Material Design
    let appBar = MDCAppBar()
    let fab = MDCFloatingButton()

    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set initial location
        mapView.delegate = self
        let initialLocation = CLLocation(latitude: 31.120312, longitude: 30.950693)
        //Zoom
        zoomMapOn(location: initialLocation)
        //JSON data
        fetchData()
        mapView.addAnnotations(mashroos)
        //Material Design - Floating Button
        view.addSubview(fab)
        fab.translatesAutoresizingMaskIntoConstraints = false
        fab.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
        fab.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        fab.backgroundColor = UIColor(red: 52/255, green: 120/255, blue: 246/255, alpha: 1)
        fab.setImage(UIImage(named: "my_location.png"), for: .normal)
        fab.addTarget(self, action: #selector(fabDidTap(sender:)), for: .touchUpInside)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //User location
        setupCoreLocation()
    }
    
    
    //MARK: - Zoom
    func zoomMapOn(location: CLLocation) {
        let cordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(cordinateRegion, animated: true)
        
    }
    
    //MARK: - Parsing JSON
    func fetchData() {
        let fileName = Bundle.main.path(forResource: "Mashroos", ofType: "json")
        let filePath = URL(fileURLWithPath: fileName!)
        var data: Data?
        do {
            data = try Data(contentsOf: filePath, options: Data.ReadingOptions(rawValue: 0))
        } catch let error {
            data = nil
            print("Report error \(error.localizedDescription)")
        }
        
        if let jsonData = data {
            do {
            let json = try JSON(data: jsonData)
            if let venueJSONs = json["response"]["mashroos"].array {
                for venueJSON in venueJSONs {
                    if let venue = Mashroos.from(json: venueJSON) {
                        self.mashroos.append(venue)
                    }
                }
            }
            } catch let error {
                
                print("error with json parsing: \(error)")
            }
        }
    }
    
    //MARK: - Current Location
    func setupCoreLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            enableLocationService()
        default:
            break
        }
    }
    
    func enableLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            mapView.setUserTrackingMode(.follow, animated: true)
        }
    }

    
    //MARK: - Actions
    //MARK: - Material Design -> Floating Button
    @objc func fabDidTap(sender: UIButton) {
        setupCoreLocation()
    }
    
    //MARK: - Store an array of CLLocationCoordinate2D
    func storeCoordinates(_ coordinates: [CLLocationCoordinate2D]) {
        let locations = coordinates.map { coordinate -> CLLocation in
            return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        let archived = NSKeyedArchiver.archivedData(withRootObject: locations)
        UserDefaults.standard.set(archived, forKey: "coordinates")
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - Return an array of CLLocationCoordinate2D
    func loadCoordinates() -> [CLLocationCoordinate2D]? {
        guard let archived = UserDefaults.standard.object(forKey: "coordinates") as? Data,
            let locations = NSKeyedUnarchiver.unarchiveObject(with: archived) as? [CLLocation] else {
                return nil
        }
        
        let coordinates = locations.map { location -> CLLocationCoordinate2D in
            return location.coordinate
        }
        
        return coordinates
    }


    
    

}

//MARK: - Extensions
extension MapViewController: MKMapViewDelegate {
    
    //MARK: - Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Mashroos {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView =
                mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.image = UIImage(named: "bus")
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .infoLight)
                view.leftCalloutAccessoryView = UIImageView(image: view.image)
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let vc = AnnotationDetailViewController(nibName: "AnnotationDetailViewController", bundle: nil)
        vc.annotation = view.annotation as! Mashroos
        present(vc, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let location = view.annotation as? Mashroos {
            self.currentPlacemark = MKPlacemark(coordinate: location.coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.green
        renderer.lineWidth = 4.0
        
        return renderer
    }
}


extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            print("autho")
        case .denied, .notDetermined:
            print("notdet")
        default:
            print("notautho")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        self.mapView.showsUserLocation = true
        zoomMapOn(location: location)
    }
}
