//
//  Mashroos.swift
//  mashroo
//
//  Created by Hassan El Desouky on 2/21/18.
//  Copyright © 2018 Hassan El Desouky. All rights reserved.
//
import Foundation
import MapKit
import Contacts
import AddressBook
import SwiftyJSON



class Mashroos: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    let mashrooPhoto: UIImage! = #imageLiteral(resourceName: "bus-k")
    
    init(title: String, locationName: String?, coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    class func from(json: JSON) -> Mashroos?
    {
        var title: String
        if let unwrappedTitle = json["name"].string {
            title = unwrappedTitle
        } else {
            title = ""
        }
        
        let locationName = json["location"]["address"].string
        let lat = json["location"]["lat"].doubleValue
        let long = json["location"]["lng"].doubleValue
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        return Mashroos(title: title, locationName: locationName, coordinate: coordinate)
    }
    
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = ("\(String(describing: title)) \(String(describing: subtitle))")
        
        return mapItem
    }
}


