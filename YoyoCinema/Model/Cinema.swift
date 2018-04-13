//
//  Cinema.swift
//  YoyoCinema
//
//  Created by Maria Lopez on 04/04/2018.
//  Copyright © 2018 Maria Lopez. All rights reserved.
//

import Foundation
import MapKit

struct Cinema : Codable {
    let html_attributions : [String]?
    let results : [Results]?
    let status : String?
}

struct Results : Codable {
    let geometry : Geometry?
    let icon : String?
    let name : String?
    let vicinity : String?
}

struct Geometry : Codable {
    let location : Location?
}

struct Location : Codable {
    let lat : Double?
    let lng : Double?
}
