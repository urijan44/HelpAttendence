//
//  Bus.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/26.
//

// BUS 모델 오브젝트

import Foundation

struct BusModel: Codable {
  var local: String
  var number: String
  var arriveStation: String
  var currentStation: String
  var remainTime: String
}
