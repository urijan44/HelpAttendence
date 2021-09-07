//
//  StationBusListModel.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/07.
//

import Foundation

class StationBusListModel: Codable {
  var adirection: String = ""
  var busRouteId: String = ""
  var rtNm: String = ""
  var stId: String = ""
  var stNm: String = ""
  var staOrd: String = ""
  var arrmsg1: String = ""
  var arrmsg2: String = ""
  var vehId1: String = ""
  var vehId2: String = ""
  var traTime1: String = ""
  var traTime2: String = ""

  enum CodingKeysError: Error {
    case keyMatchError
  }
  
  func codingKeys(_ key: String, _ property: String) throws {
    switch key {
    case "adirection":
      adirection = property
    case "busRouteId":
      busRouteId = property
    case "rtNm":
      rtNm = property
    case "stId":
      stId = property
    case "stNm":
      stNm = property
    case "staOrd":
      staOrd = property
    case "arrmsg1":
      arrmsg1 = property
    case "arrmsg2":
      arrmsg2 = property
    case "vehId1":
      vehId1 = property
    case "vehId2":
      vehId2 = property
    case "traTime1":
      traTime1 = property
    case "traTime2":
      traTime2 = property
    default:
      throw CodingKeysError.keyMatchError
    }
  }
}

extension StationBusListModel: Equatable {
  static func ==(lhs: StationBusListModel, rhs: StationBusListModel) -> Bool {
    lhs.rtNm == rhs.rtNm && lhs.stNm == rhs.stNm
  }
}
