//
//  Functions.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/09/07.
//

import Foundation

let dataSaveFailedNotification = Notification.Name(rawValue: "DataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
  print("*** Fatal error: \(error)")
  NotificationCenter.default.post(name: dataSaveFailedNotification, object: nil)
}
