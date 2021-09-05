//
//  Bus.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/26.
//

// BUS 모델 오브젝트

import Foundation

struct BusModel: Codable {
  var busRouteId: String
  var busRouteName: String
  var startStation: String
  var endStation: String
}
