//
//  BusDetailMapViewController.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/07.
//

import UIKit
import MapKit
import CoreLocation

class BusDetailMapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  var vehId1: String?
  var vehId2: String?
  var busName: String = ""
  var busLocations: [MapDetailViewBusModel] = []
  var timer: Timer?
  var timeOffset = 5
  
  var currentElement = ""
  var xmlDictionary: [String: String] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let vehId1 = vehId1, let vehId2 = vehId2 {
      getBusPosition(vehId1)
      getBusPosition(vehId2)
    }
    updateLocations()
    showBus()
    createTimer()
  }
  
  func getBusPosition(_ vehId: String) {
    let baseURLString = "http://ws.bus.go.kr/api/rest/buspos/getBusPosByVehId?"
    guard let serviceKey = Bundle.main.infoDictionary?["StationInfoKey"] as? String else { fatalError("api key not found!")}
    guard let url = URL(string: "\(baseURLString)serviceKey=\(serviceKey)&vehId=\(vehId)") else { fatalError("url convert error")}
    guard let xmlParser = XMLParser(contentsOf: url) else { return }
    xmlParser.delegate = self
    xmlParser.parse()
  }
  
  func showBus() {
    guard let busCoordinate = busLocations.first else { return }
    let region = MKCoordinateRegion(center: busCoordinate.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
    mapView.regionThatFits(region)
    mapView.setRegion(region, animated: true)
  }
  
  @IBAction func showUser() {
    let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
    mapView.setRegion(mapView.regionThatFits(region), animated: true)
  }
  
  func updateLocations() {
    mapView.removeAnnotations(busLocations)
    if busLocations.count > 2 {
      busLocations.removeFirst(2)
    }
    mapView.addAnnotations(busLocations)
  }
  
  //MARK:- Navigation
  @IBAction func backward(_ sender: UIBarButtonItem) {
    vehId1 = nil
    vehId2 = nil
    busLocations.removeAll()
    navigationController?.popViewController(animated: true)
  }
}

//MARK:- MK Map View Delegates
extension BusDetailMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    switch annotation {
    case _ as MapDetailViewBusModel:
      let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Bus") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Bus")
      annotationView.canShowCallout = true
      annotationView.glyphText = "🚌"
      annotationView.glyphImage = UIImage(systemName: "bus.fill")
      annotationView.markerTintColor = UIColor(named: "BusMarkerBackgroundColor")
      annotationView.titleVisibility = .visible
      annotationView.annotation = annotation
      return annotationView
      
    default:
      return nil
    }
    
    
  }
}


//MARK:- XMLParser Delegate

fileprivate enum XMLKey: String, CaseIterable {
  case itemList = "itemList"
  case tmX = "tmX"
  case tmY = "tmY"
}

extension BusDetailMapViewController: XMLParserDelegate {
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    currentElement = elementName
    if elementName == XMLKey.itemList.rawValue {
      xmlDictionary.removeAll()
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == XMLKey.itemList.rawValue {
      if let latitude = xmlDictionary[XMLKey.tmY.rawValue] as NSString?, let longitude = xmlDictionary[XMLKey.tmX.rawValue] as NSString? {
        let location = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        busLocations.append(MapDetailViewBusModel(coordinate: location, busName: busName))
      }
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if let key = XMLKey.init(rawValue: currentElement) {
      xmlDictionary[key.rawValue] = string
    }
  }
}

//MARK:- Timer
extension BusDetailMapViewController {
  @objc func updateTimer() {
    if timeOffset > 0 {
      timeOffset -= 1
    } else {
      timeOffset = 5
      if let vehId1 = vehId1, let vehId2 = vehId2 {
        getBusPosition(vehId1)
        getBusPosition(vehId2)
      }
      updateLocations()
      
    }
  }
  
  func createTimer() {
    let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    self.timer = timer
  }
}
