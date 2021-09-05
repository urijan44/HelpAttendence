//
//  StationDetailViewController.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/04.
//

import UIKit

class StationDetailViewController: UITableViewController {

//  let stationDetailRequest = BusListRequest()
  var routes: [Route] = [
    Route(busRouteId: "111", busRouteNm: "6512", stBegin: "구로1", stEnd: "구로5"),
    Route(busRouteId: "112", busRouteNm: "6513", stBegin: "구로2", stEnd: "구로6"),
    Route(busRouteId: "113", busRouteNm: "6514", stBegin: "구로3", stEnd: "구로7"),
    Route(busRouteId: "114", busRouteNm: "6515", stBegin: "구로4", stEnd: "구로8")
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  
  //버스 리스트 API 요청
  

//
//  func requestAPI(_ arsID: String) {
//
//    // API에서는 arsID 5자리를 무조건 요구함
//    var comparision = arsID
//    let desired = "00000"
//
//    if comparision.count < desired.count {
//      comparision.insert("0", at: comparision.startIndex)
//    }
//
//    //requst begin
//    let baseURLString = "http://ws.bus.go.kr/api/rest/stationinfo/getRouteByStation?"
//
//    guard let serviceKey = Bundle.main.infoDictionary?["StationInfoKey"] as? String else { fatalError("api key not found!")}
//    let urlString = URL(string: "\(baseURLString)serviceKey=\(serviceKey)&arsId=\(arsID)")
//
//    var request = URLRequest(url: urlString!)
//    request.httpMethod = "GET"
//
//    URLSession.shared.dataTask(with: request) { data, response, error in
//      if let data = data, let _ = response {
//        let parser = XMLParser(data: data)
//        parser.delegate = self
//        parser.parse()
//      }
//      if let error = error {
//        print(error.localizedDescription)
//      }
//    }
//    .resume()
//  }
  
  //MARK:- Helper Methods
  

  
  
  
  //MARK:- Table View Delegates
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return routes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "BusCell", for: indexPath) as? StationDetailCell else { fatalError("Could not create bus Cell")}
    let route = routes[indexPath.row]
    cell.busRouteName.text = route.busRouteNm
    cell.startStation.text = route.stBegin
    cell.destinationStation.text = route.stEnd
    return cell
  }
}

