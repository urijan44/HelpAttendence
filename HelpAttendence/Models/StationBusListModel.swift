//
//  StationBusListModel.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/07.
//

import Foundation

struct StationBusListModel {
  var adirection: String = ""
  var busRouteId: String = ""
  var rtNm: String = ""
  var stId: String = ""
  var stNm: String = ""
  var staOrd: String = ""
  var arrmsg1: String = ""
  var arrmsg2: String = ""

  enum CodingKeysError: Error {
    case keyMatchError
  }
  
  mutating func codingKeys(_ key: String, _ property: String) throws {
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
    default:
      throw CodingKeysError.keyMatchError
    }
  }
}
