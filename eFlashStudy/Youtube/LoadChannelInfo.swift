//
//  LoadChannelInfo.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 6. 20..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class LoadChannelInfo {

    let apiKey: String = "AIzaSyB7axvVjh9cQtbuqpbdBcMibbCcKDPwvPA"
    var channelIndex = 0
    var channelsDataArray: [[String: String]] = []

    let channelList: [String] = ["EnglishByJade",
                                 "AlexESLvid",
                                 "EnglishLessons4U",
                                 "EnglishTeacherAdam",
                                 "EnglishTeacherEmma",
                                 "RebeccaESL",
                                 "AsapSCIENCE",
                                 "australianetwork",
                                 "TestTubeNetwork"]

    // Alert OK (UIViewController를 받아온다.)
    func alertWithOk(fromController controller: UIViewController, setTitle: String?, setNotice: String?) {

        let alertController = UIAlertController(title: setTitle, message: setNotice, preferredStyle: .alert)
        let alertOK = UIAlertAction(title: "OK", style: .default) { (_) in
        }

        alertController.addAction(alertOK)
        controller.present(alertController, animated: true, completion: nil)
    }


    

/*
    // Youtube 체널 정보를 가져온다.
    func getYoutubeChannelDetails() {
        var urlString: String!
        let mySession = URLSession.shared

        urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(channelList[channelIndex])&key=\(apiKey)"
        let url: NSURL = NSURL(string: urlString)!

        let networkTask = mySession.dataTask(with: url as URL) { (data, response, error) -> Void in
            if error != nil {
                print("[getChannelDetails] fetch Failed : \(String(describing: error?.localizedDescription))")

            } else {
                if let data = data {
                    do {
                        let channelJSON = JSON(data: data)

                        for item in channelJSON["items"] {

                            // Create a new dictionary to store only the values we care about.
                            var desiredValuesDict: Dictionary<String, String> = Dictionary<String, String>()
                            desiredValuesDict["title"] = item.1["snippet"]["title"].stringValue
                            desiredValuesDict["description"] = item.1["snippet"]["description"].stringValue
                            desiredValuesDict["thumbnail"] = item.1["snippet"]["thumbnails"]["default"]["url"].stringValue
                            desiredValuesDict["id"] = item.1["id"].stringValue

                            // Append the desiredValuesDict dictionary to the following array.
                            StudyDataStruct.channelsDataArray.append(desiredValuesDict as [String : String])

                            print("channel : \(item.1["snippet"]["title"].stringValue)")
                        }

                        // Load the next channel data (if exist).
                        self.channelIndex += 1
                        if self.channelIndex < self.channelList.count {
                            self.getYoutubeChannelDetails()
                        }
                    }
                }
            }
        }
        networkTask.resume()
    }
 */

}
