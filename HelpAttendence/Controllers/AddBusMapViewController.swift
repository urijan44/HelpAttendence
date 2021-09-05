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
  
  //MARK:- XML Parse
  var routes: [Route] = []

  var currentElement = ""
  var xmlParser = XMLParser()
  var xmlDictionary: [String: String] = [:]

  func requestStationInfo(_ arsId: String) {
    var comparision = arsId
    let desired = "00000"
    
    if comparision.count < desired.count {
      comparision.insert("0", at: comparision.startIndex)
    }
    
    let baseURLString = "http://ws.bus.go.kr/api/rest/stationinfo/getRouteByStation?"
    
    guard let serviceKey = Bundle.main.infoDictionary?["StationInfoKey"] as? String else { fatalError("api key not found!")}
    guard let url = URL(string: "\(baseURLString)serviceKey=\(serviceKey)&arsId=\(comparision)") else { fatalError("url convert error")}
    guard let xmlParser = XMLParser(contentsOf: url) else { return }
    
    xmlParser.delegate = self
    xmlParser.parse()
  }

  
  
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
  
  //정류소 도착 정보 표시
  @objc func showStationDetail(_ sender: UIButton) {
    performSegue(withIdentifier: "showDetailStation", sender: sender)
  }
  
  
  //MARK:- Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetailStation" {
      let controller = segue.destination as! StationDetailViewController
      let button = sender as! UIButton
      let station = stations[button.tag]
      
      requestStationInfo(station.ARSID)
      controller.routes = routes
    }
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
    case _ as BusStationModel:
      let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Station") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Station")
      annotationView.canShowCallout = true
      annotationView.glyphText = "🚌"
      annotationView.clusteringIdentifier = "Cluster"
      annotationView.markerTintColor = UIColor(named: "BusMarkerBackgroundColor")
      annotationView.titleVisibility = .visible

      let rightButton = UIButton(type: .detailDisclosure)
      rightButton.addTarget(self, action: #selector(showStationDetail(_:)), for: .touchUpInside)
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

enum XMLKey: String {
  case busRouteId = "busRouteId"
  case busRouteNm = "busRouteNm"
  case stBegin = "stBegin"
  case stEnd = "stEnd"
}

struct Routes {
  let route: [Route]
}

struct Route {
  var busRouteId: String = ""
  var busRouteNm: String = ""
  var stBegin: String = ""
  var stEnd: String = ""
}


//MARK:- XMLParser Delegats
extension AddBusMapViewController: XMLParserDelegate {
  
  
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElement = elementName
    if elementName == "itemList" {
      xmlDictionary.removeAll()
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == "itemList" {
      guard let busRouteId = xmlDictionary["busRouteId"],
      let busRouteNm = xmlDictionary["busRouteNm"],
      let stBegin = xmlDictionary["stBegin"],
      let stEnd = xmlDictionary["stEnd"] else { return }
      
      let route = Route(busRouteId: busRouteId, busRouteNm: busRouteNm, stBegin: stBegin, stEnd: stEnd)
      routes.append(route)
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    switch currentElement {
    case "busRouteId":
      xmlDictionary["busRouteId"] = string
    case "busRouteNm":
      xmlDictionary["busRouteNm"] = string
    case "stBegin":
      xmlDictionary["stBegin"] = string
    case "stEnd":
      xmlDictionary["stEnd"] = string
    default:
      break
    }
  }

}
