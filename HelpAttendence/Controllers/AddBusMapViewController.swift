//
//  AddBusMapViewController.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/31.
//

import UIKit
import MapKit

class AddBusMapViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  
  var busStationStore: BusStationStore!
  var stations: [BusStationModel] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 정류소 정보 로드
    do {
      busStationStore = try BusStationStore()
      stations = busStationStore.stations
    } catch {
      print(error.localizedDescription)
      stationDataNotFoundAlert()
    }
    
    
    updateLocations()
  }
  
  
  
  //MARK:- Actions
  @IBAction func showUser() {
    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    mapView.setRegion(mapView.regionThatFits(region), animated: true)
  }
  
  //MARK:- Helper Metohds
  
  //정류소 정보를 불러올 수 없을 때 알람 출력
  private func stationDataNotFoundAlert() {
    let alert = UIAlertController(title: "정류소 정보 다운로드 실패", message: "정류소 정보를 가져오는데 실패했습니다.\nteamsva360@gmail.com\n 로 문의를 남겨주세요", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "확인", style: .default)
    alert.addAction(okAction)
    
    present(alert, animated: true)
  }
  
  //지도에 정류소 Annotations 표시
  func updateLocations() {
    mapView.removeAnnotations(stations)
    mapView.addAnnotations(stations)
  }
}

// MK Map View Delegates

extension AddBusMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is BusStationModel else {
      return nil
    }
    
    let identifier = "Station"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
    if annotationView == nil {
      let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      pinView.isEnabled = true
      pinView.canShowCallout = true
      pinView.animatesDrop = false
      pinView.pinTintColor = UIColor(red: 0.2, green: 0.2, blue: 1, alpha: 1)
      
      let rightButton = UIButton(type: .detailDisclosure)
      pinView.rightCalloutAccessoryView = rightButton
      annotationView = pinView
    }
    
    if let annotationView = annotationView {
      annotationView.annotation = annotation
      
      let button = annotationView.rightCalloutAccessoryView as! UIButton
      if let index = stations.firstIndex(of: annotation as! BusStationModel) {
        button.tag = index
      }
    }
    return annotationView
  }
}
