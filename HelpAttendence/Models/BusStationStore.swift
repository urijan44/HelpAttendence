//
//  BusStationStore.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/27.
//

import Foundation

// 정류소 역을 저장하기 위한 클래스
class BusStationStore {
  
  private enum BusStationStoreError: Error {
    case urlFailure, fileNotFound, downFailure
  }
  
  // 정류소 역 저장 배열
  var stations: [BusStationModel] = []
  
  // 정류소 정보 파일 저장 위치
  private func getURL() -> URL? {
    guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
    return documentsURL.appendingPathComponent("SeoulBusStationData.plist")
  }
  
  
  // 정류소 파일이 디바이스에 저장되어 있지 않을 때 웹에 요청해서 파일을 가져옴
  private func networkRequest() throws {
    guard let urlstr = URLComponents(string: "https://github.com/urijan44/api-test-repo/raw/main/SeoulBusStationData.plist") else {
      print("url convert fail")
      throw BusStationStoreError.urlFailure
    }
    
    let request = URLRequest(url: urlstr.url!)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print(error.localizedDescription)
      }
      if let data = data {
        let decoder = PropertyListDecoder()
        do {
          self.stations = try decoder.decode([BusStationModel].self, from: data)
          try self.save()
        } catch let DecodingError.dataCorrupted(context) {
          print(context)
        } catch let DecodingError.keyNotFound(key, context) {
          print("Key '\(key)' not found:", context.debugDescription)
          print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
          print("Value '\(value)' not found:", context.debugDescription)
          print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
          print("Type '\(type)' mismatch:", context.debugDescription)
          print("codingPath:", context.codingPath)
        } catch {
          print("error: ", error)
        }
      }
      if let response = response {
        print(response.description)
      }
    }
    .resume()
  }
  
  private func save() throws {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .binary
    
    guard let url = getURL() else {
      print("url failure")
      return
    }
    
    if !stations.isEmpty {
      do {
        let encodeData = try encoder.encode(stations)
        try encodeData.write(to: url, options: .atomic)
      } catch let EncodingError.invalidValue(type, context) {
        print("invalidValue")
        print("type: \(type), context: \(context.debugDescription)")
        print("\(context.codingPath)")
      }
    } else {
      print("stations data is empty")
    }
  }
  
  private func load() throws -> [BusStationModel] {
    
    guard let url = getURL() else {
      throw BusStationStoreError.urlFailure
    }
    let decoder = PropertyListDecoder()
    
    let contents: Data
    do {
      contents = try Data(contentsOf: url)
    } catch {
      print(error.localizedDescription)
      throw BusStationStoreError.fileNotFound
    }
    
    var decodedData: [BusStationModel] = []
    do {
      decodedData = try decoder.decode([BusStationModel].self, from: contents)
    } catch let DecodingError.dataCorrupted(context) {
      print(context)
    } catch let DecodingError.keyNotFound(key, context) {
      print("Key '\(key)' not found:", context.debugDescription)
      print("codingPath:", context.codingPath)
    } catch let DecodingError.valueNotFound(value, context) {
      print("Value '\(value)' not found:", context.debugDescription)
      print("codingPath:", context.codingPath)
    } catch let DecodingError.typeMismatch(type, context)  {
      print("Type '\(type)' mismatch:", context.debugDescription)
      print("codingPath:", context.codingPath)
    } catch {
      print("error: ", error)
    }
    
    return decodedData
  }
  
  init() throws {
    do {
      stations = try load()
    } catch {
      print(error.localizedDescription)
      try networkRequest()
    }
  }
}
