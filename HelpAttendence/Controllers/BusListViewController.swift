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
  
  let locationManager = CLLocationManager()
  var stations: BusStationStore?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationInit()
    

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
    
    //MARK:- Helper Methods
    func showLocationServicesDeniedAlert() {
      let alert = UIAlertController(title: "위치 서비스 비활성화", message: "앱 설정에서 위치 서비스를 활성화 해주세요.", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "확인", style: .default)
      alert.addAction(okAction)
      
      present(alert, animated: true)
    }
    
  }
  
  
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
