//
//  UserBusInformationModel.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/05.
//

import Foundation

struct UserBusInfoModel: Codable {
  let local: String
  let number: String
  let arriveStation: String
  var currentStation: String
  var remainTime: String
}
