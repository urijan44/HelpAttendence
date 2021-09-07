//
//  StationDetailViewController.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/04.
//

import UIKit

class StationDetailViewController: UITableViewController {
  
  var arsId: String?
  
  //버스 정보 요청 api
  //MARK:- XML Parse
  var routes: [StationBusListModel] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  
  var selectRoute: StationBusListModel?

  var currentElement = ""
  
  var xmlDictionary: [String: String] = [:]

  func requestStationInfo(_ arsId: String) {
    var comparision = arsId
    let desired = "00000"
    
    if comparision.count < desired.count {
      comparision.insert("0", at: comparision.startIndex)
    }
    
    let baseURLString = "http://ws.bus.go.kr/api/rest/stationinfo/" + Constants.URL.getStationByUid
    
    guard let serviceKey = Bundle.main.infoDictionary?["StationInfoKey"] as? String else { fatalError("api key not found!")}
    guard let url = URL(string: "\(baseURLString)serviceKey=\(serviceKey)&arsId=\(comparision)") else { fatalError("url convert error")}
    guard let xmlParser = XMLParser(contentsOf: url) else { return }
    
    xmlParser.delegate = self
    xmlParser.parse()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let arsId = arsId {
      requestStationInfo(arsId)
    } else {
      print("error arsId is nil!")
    }
    
  }

  //MARK:- Table View Delegates
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return routes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BusCell", for: indexPath)
    let route = routes[indexPath.row]
    cell.textLabel?.text = route.rtNm
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectRoute = routes[indexPath.row]
    performSegue(withIdentifier: "AddArriveInfo", sender: nil)
  }
}

//MARK:- XMLParser Delegats
fileprivate enum XMLKey: String, CaseIterable {
  case itemList = "itemList"
  case adirection = "adirection"
  case busRouteId = "busRouteId"
  case rtNm = "rtNm"
  case stId = "stId"
  case stNm = "stNm"
  case staOrd = "staOrd"
}

extension StationDetailViewController: XMLParserDelegate {
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElement = elementName
    if elementName == XMLKey.itemList.rawValue {
      xmlDictionary.removeAll()
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == XMLKey.itemList.rawValue {
      let route = StationBusListModel()
      XMLKey.allCases.forEach { key in
        if let value = xmlDictionary[key.rawValue] {
          do {
            try route.codingKeys(key.rawValue, value)
          } catch {
            print(error)
          }
        }
      }
      routes.append(route)
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if let key = XMLKey.init(rawValue: currentElement) {
      xmlDictionary[key.rawValue] = string
    }
  }

}
