//
//  MapDetailViewBusModel.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/07.
//

import Foundation
import CoreLocation
import MapKit

class MapDetailViewBusModel: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  var busName: String
  
  init(coordinate: CLLocationCoordinate2D, busName: String) {
    self.coordinate = coordinate
    self.busName = busName
  }
  
  public var title: String? {
    return busName
  }
}

