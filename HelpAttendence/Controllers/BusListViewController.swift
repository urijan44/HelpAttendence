//
//  BusListView.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/26.
//

import UIKit
import CoreLocation

class BusListViewController: UITableViewController {
  
  var myBusStore: [StationBusListModel] = [] {
    didSet {
      reloadAPI()
      tableView.reloadData()
    }
  }
  
  var seconds = 10
  
  @IBOutlet weak var addBusMap: UIBarButtonItem!
  
  let locationManager = CLLocationManager()
  var stations: BusStationStore?
  
  var updateLocation = false
  var lastLocationError: Error?
  var userLocation: CLLocation? {
    didSet {
      if userLocation != nil {
        addBusMap.isEnabled = true
      }
    }
  }
  var timer: Timer?
  var arriveTime: Timer?
  
  // XML parser property
  var currentElement = ""
  var xmlParser = XMLParser()
  var xmlDictionary: [String: String] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationInit()
    if userLocation == nil {
      addBusMap.isEnabled = false
    }
    
    reloadAPI()
    createTimer()
  }
  
  
  func locationInit() {
    let authStatus = locationManager.authorizationStatus
    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    
    if authStatus == .denied || authStatus == .restricted {
      showLocationServicesDeniedAlert()
      return
    }
    
    if updateLocation {
      stopLocationManager()
    } else {
      userLocation = nil
      startLocationManager()
    }
  }
  
  //MARK:- Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddBusMap" {
      let controller = segue.destination as! AddBusMapViewController
      controller.userLocation = userLocation
    }
  }
  
  @IBAction func addBusList(unwindSegue: UIStoryboardSegue) {
    guard let stationDetailViewController = unwindSegue.source as? StationDetailViewController, let route = stationDetailViewController.selectRoute else { return }
    if !myBusStore.contains(route) {
      myBusStore.append(route)
    } else {
      print("이미 있는 경로입니다!")
    }
    tableView.reloadData()
  }
  
  //MARK:- Helper Methods
  
  //XML Parser
  //bus arrive message update
  func updateBusInformation(_ requestModel: StationBusListModel) {
    let baseURLString = "http://ws.bus.go.kr/api/rest/arrive/getArrInfoByRoute?"
    guard let serviceKey = Bundle.main.infoDictionary?["StationInfoKey"] as? String else { fatalError("api key not found!")}
    guard let url = URL(string: "\(baseURLString)serviceKey=\(serviceKey)&stId=\(requestModel.stId)&busRouteId=\(requestModel.busRouteId)&ord=\(requestModel.staOrd)") else { fatalError("url convert error")}
    guard let xmlParser = XMLParser(contentsOf: url) else { return }
    xmlParser.delegate = self
    xmlParser.parse()
    tableView.reloadData()
  }
  
  func showLocationServicesDeniedAlert() {
    let alert = UIAlertController(title: "위치 서비스 비활성화", message: "앱 설정에서 위치 서비스를 활성화 해주세요.", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "확인", style: .default)
    alert.addAction(okAction)
    
    present(alert, animated: true)
  }
  
  func stopLocationManager() {
    if updateLocation {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
      updateLocation = false
      if let timer = timer {
        timer.invalidate()
      }
    }
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      print("startUpdatingLocation")
      updateLocation = true
      timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
    }
  }
  
  @objc func didTimeOut() {
    print("*** Time out")
    if userLocation == nil {
      stopLocationManager()
    }
  }
  
  //bus info reload
  @IBAction func reloadAPI() {
    if !myBusStore.isEmpty {
      myBusStore.forEach { model in
        updateBusInformation(model)
      }
    }
  }
  
  
  //MARK:- Table View Data Source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    myBusStore.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(BusListCell.self)", for: indexPath) as? BusListCell else { fatalError("Could not create bus Cell")}
    let route = myBusStore[indexPath.row]
    cell.arriveLocation.text = route.stNm
    cell.busNumber.text = route.rtNm
    cell.remainTime.text = route.arrmsg1
    cell.nextTime.text = route.arrmsg2
    cell.busImage.image = UIImage(systemName: "b.square.fill")
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    myBusStore.remove(at: indexPath.row)
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }
}


//MARK:- CoreLocation Manager Delegtes
extension BusListViewController: CLLocationManagerDelegate {
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("didFailWithError \(error.localizedDescription)")
    if (error as NSError).code == CLError.locationUnknown.rawValue {
      return
    }
    lastLocationError = error
    stopLocationManager()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    print("didUpdateLocations \(newLocation)")
    
    // 1
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    if userLocation == nil || userLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
      lastLocationError = nil
      userLocation = newLocation
    }
    
    if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
      print("*** We're done!")
      stopLocationManager()
    }
  }
}

//MARK:- XMLParser Delegates

fileprivate enum XMLKey: String, CaseIterable {
  case itemList = "itemList"
  case arrmsg1 = "arrmsg1"
  case arrmsg2 = "arrmsg2"
  case vehId1 = "vehId1"
  case vehId2 = "vehId2"
  case rtNm = "rtNm"
  case stNm = "stNm"
  case traTime1 = "traTime1"
  case traTime2 = "traTime2"
}

extension BusListViewController: XMLParserDelegate {
  
  // Get data list
  // arrmsg1, arrmsg2, vhid1, vhid2,
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
      
      myBusStore.forEach { model in
        if route == model{
          model.arrmsg1 = route.arrmsg1
          model.arrmsg2 = route.arrmsg2
          model.vehId1 = route.vehId1
          model.vehId2 = route.vehId2
          model.traTime1 = route.traTime1
          model.traTime2 = route.traTime2
        }
      }
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if let key = XMLKey.init(rawValue: currentElement) {
      if key == .arrmsg1 || key == .arrmsg2 {
        if xmlDictionary[key.rawValue] == nil {
          xmlDictionary[key.rawValue] = string
        } else {
          xmlDictionary[key.rawValue]?.append(string)
        }
      } else {
        xmlDictionary[key.rawValue] = string
      }
    }
  }
}

//MARK:- Timer
extension BusListViewController {
  @objc func updateTimer() {
    guard let visibleRowsIndexPaths = tableView.indexPathsForVisibleRows else { return }
    for indexPath in visibleRowsIndexPaths {
      if let cell = tableView.cellForRow(at: indexPath) as? BusListCell {
        cell.updateTime(myBusStore[indexPath.row])
      }
    }
  }
  
  func createTimer() {
    let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    self.arriveTime = timer
  }
  
  func cancelTimer() {
    arriveTime?.invalidate()
    arriveTime = nil
  }
}
