//
//  BusListRequest.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/05.
//

import Foundation

struct BusListRequest {
  let baseURLString = "http://ws.bus.go.kr/api/rest/stationinfo/getRouteByStation?"
  
  func requestAPI(arsID: String) -> Data? {
    guard let serviceKey = Bundle.main.infoDictionary?["StationInfoKey"] as? String else { fatalError("api key not found!")}
    //percent encoding
    var resultData: Data?
    let urlString = URL(string: "\(baseURLString)serviceKey=\(serviceKey)&arsId=\(arsID)")
    
      
    var request = URLRequest(url: urlString!)
    request.httpMethod = "GET"
    
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let data = data, let _ = response {
        resultData = data
      }
      if let error = error {
        print(error.localizedDescription)
      }
    }
    .resume()
    return resultData
  }
}
