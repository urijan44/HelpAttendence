//
//  BusListView.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/26.
//

import UIKit
import CoreLocation

class BusListViewController: UITableViewController {
  
  var myBusStorage = MyBusStorage(withLoadCheck: true) {
    didSet {
      reloadAPI()
      tableView.reloadData()
    }
  }
  
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
  
  var selectBusIndex = 0
  
  // XML parser property
  var currentElement = ""
  
  var xmlDictionary: [String: String] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    do {
      let _ = try BusStationStore()
    } catch {
      print(error.localizedDescription)
    }
    locationInit()
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
      if userLocation == nil {
        controller.userLocation = CLLocation(latitude: 37.551251, longitude: 126.988322)
      } else {
        controller.userLocation = userLocation
      }
      locationInit()
    }
    
    if segue.identifier == "ShowBusPosition" {
      let controller = segue.destination as! BusDetailMapViewController
      
      controller.vehId1 = myBusStorage.myBusStore[selectBusIndex].vehId1
      controller.vehId2 = myBusStorage.myBusStore[selectBusIndex].vehId2
      controller.busName = myBusStorage.myBusStore[selectBusIndex].rtNm
    }
  }
  
  @IBAction func addBusList(unwindSegue: UIStoryboardSegue) {
    guard let stationDetailViewController = unwindSegue.source as? StationDetailViewController, let route = stationDetailViewController.selectRoute else { return }
    if !myBusStorage.myBusStore.contains(route) {
      myBusStorage.myBusStore.append(route)
      myBusStorage.saveMyBusStore()
      reloadAPI()
    } else {
      print("?????? ?????? ???????????????!")
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
    let alert = UIAlertController(title: "?????? ????????? ????????????", message: "??? ???????????? ?????? ???????????? ????????? ????????????.", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "??????", style: .default)
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
    if !myBusStorage.myBusStore.isEmpty {
      myBusStorage.myBusStore.forEach { model in
        updateBusInformation(model)
      }
    }
  }
  
  
  //MARK:- Table View Delegates
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    myBusStorage.myBusStore.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(BusListCell.self)", for: indexPath) as? BusListCell else { fatalError("Could not create bus Cell")}
    let route = myBusStorage.myBusStore[indexPath.row]
    cell.arriveLocation.text = route.stNm
    cell.busNumber.text = route.rtNm
    cell.remainTime.text = route.arrmsg1
    cell.nextTime.text = route.arrmsg2
    cell.busImage.image = UIImage(systemName: "b.square.fill")
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    myBusStorage.myBusStore.remove(at: indexPath.row)
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
    myBusStorage.saveMyBusStore()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectBusIndex = indexPath.row
    performSegue(withIdentifier: "ShowBusPosition", sender: nil)
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
      
      myBusStorage.myBusStore.forEach { model in
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
        cell.updateTime(myBusStorage.myBusStore[indexPath.row])
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
