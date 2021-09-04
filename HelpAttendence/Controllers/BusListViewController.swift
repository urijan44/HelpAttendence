//
//  BusListView.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/26.
//

import UIKit
import CoreLocation

class BusListView: UITableViewController {
  
  //테스트용 더미 데이터
  var dummyBus: [BusModel] = [
    BusModel(local: "서울", number: "6512", arriveStation: "구로디지털단지역", currentStation: "해피랜드", remainTime: "15분"),
    BusModel(local: "서울", number: "구로09", arriveStation: "구로디지털단지역환승센터", currentStation: "해피랜드", remainTime: "100분"),
    BusModel(local: "서울", number: "6514", arriveStation: "구로디지털단지역", currentStation: "해피랜드", remainTime: "10분"),
    BusModel(local: "서울", number: "5618", arriveStation: "구로디지털단지역", currentStation: "해피랜드", remainTime: "2분"),
  ]
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationInit()
    if userLocation == nil {
      addBusMap.isEnabled = false
    }
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
  
  //MARK:- Helper Methods
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
  
  //화면이 표시되거나 리프레시 버튼이 눌렸을 때 도착정보를 갱신하는 메소드
  //저장된 버스/스테이션 정보를 API에 요청하는 식으로 동작
  //꼭 구현해야 함
  //func updateArriveInfomation()
  
  
  //MARK:- Table View Data Source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    dummyBus.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(BusListCell.self)", for: indexPath) as? BusListCell else { fatalError("Could not create bus Cell")}
    let bus = dummyBus[indexPath.row]
    cell.busLocation.text = bus.local
    cell.arriveLocation.text = bus.arriveStation
    cell.busNumber.text = bus.number
    cell.remainTime.text = bus.remainTime
    cell.busImage.image = UIImage(systemName: "b.square.fill")
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    dummyBus.remove(at: indexPath.row)
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }
}


extension BusListView: CLLocationManagerDelegate {
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
