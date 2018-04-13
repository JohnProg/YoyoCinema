//
//  FirstView.swift
//  YoyoCinema
//
//  Created by Maria Lopez on 16/03/2018.
//  Copyright © 2018 Maria Lopez. All rights reserved.
//

import UIKit
import MapKit
import Alamofire


class FirstView: UIViewController, MKMapViewDelegate{
    @IBOutlet weak var mapView: MKMapView!
    
    var completedUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.173417,-3.599750&radius=2000&type=movie_theater&key=AIzaSyCKRqgpEasNH8XgUfcEf9zOZyIuE1LB1WE"
    var results = [Results]()
    
    var userLocation: MKUserLocation! {
        didSet {
            if userLocation != nil {
                completedUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&radius=2000&type=movie_theater&key=AIzaSyCKRqgpEasNH8XgUfcEf9zOZyIuE1LB1WE"
                alamofireRequest(url: completedUrl)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.register(ClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AnalyticsManager.sharedInstance.registerScreen(screenName: "Map")
    }
    
    @IBAction func ZoomIn(_ sender: Any) {
        userLocation = mapView.userLocation
        let region = MKCoordinateRegionMakeWithDistance((userLocation.location?.coordinate)!, 2000, 2000)
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - Map Annotations
    func addMarkers(){
        
            for cinema in results {
                var placeName = ""
                var placeAddress = ""
                var latitude = 0.0
                var longitude = 0.0
                
                placeName = cinema.name!
                placeAddress = cinema.vicinity!
                latitude = (cinema.geometry?.location?.lat!)!
                longitude = (cinema.geometry?.location?.lng!)!
                
                let marker = Annotation(title: "\(placeName)",
                                        address: "\(placeAddress)",
                                        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                
                var markers = [Annotation]()
                markers.append(marker)
                mapView.addAnnotations(markers)
            }
    }
    
    //MARK: - custom annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Annotation else { return nil }
       
        let identifier = "marker"
        var view: MKMarkerAnnotationView
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            view.markerTintColor = .purple
            view.glyphImage = #imageLiteral(resourceName: "camera")
            view.clusteringIdentifier = "cinema"

        return view
    }
    //MARK: - Launching the Maps App/ Route
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Annotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    //MARK: - Alamofire
    func alamofireRequest(url: String) {
        Alamofire.request(url)
            .responseJSON { response in
                
                switch response.result {
                    
                case .success:
                    //retrieving the response as data to decode it
                    guard let result = response.data else { return }
                    do{
                        if let cinema = try JSONDecoder().decode(Cinema.self, from: result) as? Cinema
                        {
                            self.results = cinema.results!
                            self.addMarkers()
                        }
                    } catch let error {
                        print ("Error JSONDecoder ->\(error)")
                    }
                    
                case .failure(_):
                    print("Error-> request = failure")
                }
        }
    }
}

