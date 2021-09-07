//
//  MyBusStorage.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/07.
//

import Foundation

private enum FileError: Error {
  case saveFailure, loadFailure, urlError
}

class MyBusStorage {
  var myBusStore: [StationBusListModel] = []
  
  private func getURL() throws -> URL {
    guard let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      throw FileError.urlError
    }
    return paths.appendingPathComponent("MyBusStorage.plist")
  }

  func saveMyBusStore() {
    let encoder = PropertyListEncoder()
    do {
      let path = try getURL()
      let data = try encoder.encode(myBusStore)
      try data.write(to: path, options: .atomic)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func loadMyBusStore() throws {
    let decoder = PropertyListDecoder()
    do {
      let path = try getURL()
      let contents = try Data(contentsOf: path)
      myBusStore = try decoder.decode([StationBusListModel].self, from: contents)
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
      print("error: ", error.localizedDescription)
    }
  }
  
  init(withLoadCheck: Bool) {
    do {
      try loadMyBusStore()
    } catch {
      myBusStore = []
      print(error.localizedDescription)
    }
  }
}
