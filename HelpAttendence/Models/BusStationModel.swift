//
//  BusStationModel.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/27.
//

import Foundation
import MapKit

//Bus 정류소 모델

class BusStationModel: NSObject, Codable {
  let standardID: String
  let ARSID: String
  let name: String
  let longitude: Double
  let latitude: Double
}

extension BusStationModel: Identifiable {
  
}


// MKAnnotation 확장

extension BusStationModel: MKAnnotation {
  public var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }
  
  // 정류소 탭시 버스 정류소 이름 표시 목적
  public var title: String? {
    return name
  }
}
