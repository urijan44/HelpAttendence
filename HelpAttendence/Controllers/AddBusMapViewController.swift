//
//  AddBusMapViewController.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/31.
//

import UIKit
import MapKit
import CoreLocation

class AddBusMapViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  
  var busStationStore: BusStationStore!
  var stations: [BusStationModel] = []
  var userLocation: CLLocation?
  
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
    
    if let userLocation = userLocation {
      print("setFit")
      let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
      mapView.regionThatFits(region)
      mapView.setRegion(region, animated: true)
    } else {
      print("user location nil")
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
  }
  
  
  
  //MARK:- Actions
  @IBAction func showUser() {
    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
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
    
    switch annotation {
    case let cluster as MKClusterAnnotation:
      let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Cluster") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Cluster")
      annotationView.markerTintColor = UIColor(named: "BusMarkerBackgroundColor")
      
      for clusterAnnotation in cluster.memberAnnotations {
        if let station = clusterAnnotation as? BusStationModel {
          cluster.title = station.name
          break
        }
      }
      annotationView.titleVisibility = .visible
      return annotationView
    case let stationAnnotation as BusStationModel:
      let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Station") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Station")
      annotationView.canShowCallout = true
      annotationView.glyphText = "🚌"
      annotationView.clusteringIdentifier = "Cluster"
      annotationView.markerTintColor = UIColor(named: "BusMarkerBackgroundColor")
      annotationView.titleVisibility = .visible

      let rightButton = UIButton(type: .detailDisclosure)
      annotationView.rightCalloutAccessoryView = rightButton

      annotationView.annotation = annotation
      let button = annotationView.rightCalloutAccessoryView as! UIButton
      if let index = stations.firstIndex(of: annotation as! BusStationModel) {
        button.tag = index
      }
      return annotationView
      
    default:
      return nil
    }
  }
}
