//
//  AnnotationDetailViewController.swift
//  PizzaHistoryMap
//
//  Created by Steven Lipton on 7/20/17.
//  Copyright © 2017 Steven Lipton. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MaterialComponents
import MaterialComponents.MaterialAppBar
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialCollections


class AnnotationDetailViewController: UIViewController {
    
    //MARK: - Properties
    var annotation: Mashroos!

    //MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var addressText: UITextView!
    
    //MARK: - Actions
    //Done button
    @IBAction func done(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //Show directions button
    @IBAction func showDirection(_ sender: Any) {
        let coordinate = annotation.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        mapItem.name = "Target Destination"
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        mapItem.openInMaps(launchOptions: launchOptions)
        
    }
    @IBAction func favoriteAct(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(annotation.title, forKey: "titlw")
        userDefaults.set(annotation.locationName, forKey: "locationName")
        //userDefaults.set(annotation.coordinate, forKey: "coordinate")
        
        let imageData = UIImagePNGRepresentation(annotation.mashrooPhoto)
        userDefaults.set(imageData, forKey: "img")
        
        userDefaults.synchronize()
    }
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //The class model
        titleLabel.text = annotation.title
        addressText.text = annotation.locationName
        photo.image = annotation.mashrooPhoto
        
        //Place mark function
        placemark(annotation: annotation) { (placemark) in
            if let placemark = placemark {
                var locationString: String = ""
                if let city = placemark.locality {
                    locationString += city + ",  "
                }
                if let state = placemark.administrativeArea {
                    locationString += state + ",  "
                }
                if let country = placemark.country {
                    locationString += country + "."
                }
                self.addressText.text = locationString + "\n\n" + self.annotation.locationName!
            } else {
                print("not found")
            }
        }
        
    }
    
    
    //MARK: - Placemark
    func placemark(annotation: Mashroos, completionHandler: @escaping(CLPlacemark?) -> Void) {
        let coordinate = annotation.coordinate
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemarks = placemarks {
                completionHandler(placemarks.first)
            } else {
                completionHandler(nil)
            }
            
        }
    }

    

}
