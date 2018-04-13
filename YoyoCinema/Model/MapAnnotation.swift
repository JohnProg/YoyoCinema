//
//  MapAnnotation.swift
//  YoyoCinema
//
//  Created by Maria Lopez on 05/04/2018.
//  Copyright © 2018 Maria Lopez. All rights reserved.
//

import MapKit
import Contacts

class Annotation: NSObject, MKAnnotation {
    let title: String?
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    var subtitle: String? {
        return address
    }
    
    init(title: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.address = address
        self.coordinate = coordinate
        
        super.init()
    }
    
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}

class CinemaView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            if let bike = newValue as? Annotation {
                clusteringIdentifier = "bike"
                if bike.type == .unicycle {
                    markerTintColor = UIColor(named: "unicycleCol")
                    glyphImage = UIImage(named: "unicycle")
                    displayPriority = .defaultLow
                } else {
                    markerTintColor = UIColor(named: "tricycleCol")
                    glyphImage = UIImage(named: "tricycle")
                    displayPriority = .defaultHigh
                }
            }
        }
    }
    
}

