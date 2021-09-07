//
//  BusListCell.swift
//  HelpAttendence
//
//  Created by hoseung Lee on 2021/08/29.
//

import UIKit

class BusListCell: UITableViewCell {
  @IBOutlet weak var busImage: UIImageView!
  @IBOutlet weak var busNumber: UILabel!
  @IBOutlet weak var arriveLocation: UILabel!
  @IBOutlet weak var remainTime: UILabel!
  @IBOutlet weak var nextTime: UILabel!
  
  func updateTime(_ cell: StationBusListModel) {
    guard var arrTime1 = Int(cell.traTime1) else { return }
    if arrTime1 > 0 {
      arrTime1 -= 1
      let newTime1 = timeToConvertLabel(arrTime1)
      if var arrTimeText1 = remainTime.text {
        if let hoo = arrTimeText1.firstIndex(of: "후") {
          arrTimeText1.replaceSubrange(arrTimeText1.startIndex...hoo, with: newTime1)
          remainTime.text = arrTimeText1
        }
      }
      cell.traTime1 = String(arrTime1)
    } else {
      let navigationController = window!.rootViewController as! UINavigationController
      let controller = navigationController.viewControllers[0] as! BusListViewController
      controller.reloadAPI()
    }
    
    guard var arrTime2 = Int(cell.traTime2) else { return }
    arrTime2 -= 1
    let newTime2 = timeToConvertLabel(arrTime2)
    if var arrTimeText2 = nextTime.text {
      if let hoo = arrTimeText2.firstIndex(of: "후") {
        arrTimeText2.replaceSubrange(arrTimeText2.startIndex...hoo, with: newTime2)
        nextTime.text = arrTimeText2
      }
    }
    cell.traTime2 = String(arrTime2)
  }
  
  private func timeToConvertLabel(_ time: Int) -> String {
    //괄호를 분리 한다.
    var text = ""
    var retmainTraTime = time
    let minute = retmainTraTime / 60
    retmainTraTime = retmainTraTime - minute * 60
    if minute > 0 {
      text.append("\(minute)분")
    }
    let seconds = retmainTraTime
    text.append("\(seconds)초후")
    
    return text
  }
}
