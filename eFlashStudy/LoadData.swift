//
//  LoadData.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 4. 5..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

// json 파일에 있는 데이터를 카테고리별로 담는다.
struct StudyDataStruct {
    static var words = [FSProtocal]()
    static var patterns = [FSProtocal]()
    static var dialogues = [FSProtocal]()
    static var ebs = [FSProtocal]()
    static var channelsDataArray = [[String: String]]()
}

class LoadData {

    /// FlashCategory로 Json 파일 이름을 확인한다.
    static func categoryToJsonFileName(category: FlashCategory) -> String {
        var returnValue: String = ""

        switch category {
        case .word: returnValue = "flashstudy_words"
        case .pattern: returnValue = "flashstudy_patterns"
        case .dialogue: returnValue = "flashstudy_dialogues"
        case .ebs: returnValue = "flashstudy_ebs"
        case .flashword: returnValue = "flashstudy_words"
        }

        return returnValue
    }

    /// FlashCategory를 배열로 받아 Json에 있는 데이터를 StudyDataStruct에 담는다.
    static func putData(categoryArray: [FlashCategory]) {
        var jsonFileName = String()

        for category in categoryArray {
            jsonFileName = categoryToJsonFileName(category: category)

            let jsonFileUrl = Bundle.main.url(forResource: jsonFileName, withExtension: "json")!
            let wordsData = try? String(contentsOf: jsonFileUrl, encoding: String.Encoding.utf8)

            if let dataFromString = wordsData?.data(using: .utf8, allowLossyConversion: false) {
                let json = JSON(data: dataFromString)

                for jsonData in json["voca"] {
                    let flashData: FSProtocal = FSStruct(title: jsonData.1["title"].stringValue,
                                                         means: jsonData.1["means"].stringValue,
                                                         explains: jsonData.1["explains"].stringValue)

                    if category == .word {
                        StudyDataStruct.words.append(flashData)
                    } else if category == .pattern {
                        StudyDataStruct.patterns.append(flashData)
                    } else if category == .dialogue {
                        StudyDataStruct.dialogues.append(flashData)
                    } else if category == .ebs {
                        StudyDataStruct.ebs.append(flashData)
                    } else {
                        return
                    }
                }
            }
        }

        print("Word Count: \(StudyDataStruct.words.count)")
        print("Pattern Count: \(StudyDataStruct.patterns.count)")
        print("Dialogue Count: \(StudyDataStruct.dialogues.count)")
        print("EBS Count: \(StudyDataStruct.ebs.count)")
    }

    /// Alamofire를 통해 연결합니다.
    func getYoutubeChannelDetails() {
        var channelList = [String]()
        let apiKey: String = "AIzaSyB7axvVjh9cQtbuqpbdBcMibbCcKDPwvPA"

        // json 파일에서 channel 정보를 불러온다.
        let jsonFileUrl = Bundle.main.url(forResource: "youtubeChannelList", withExtension: "json")!
        let channelData = try? String(contentsOf: jsonFileUrl, encoding: String.Encoding.utf8)

        if let dataFromString = channelData?.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)

            for jsonData in json["youtube"]["channelList"] {
                channelList.append(jsonData.1["id"].stringValue)
            }
        }

        // channelList로 channel 정보를 불러온다.
        for index in 0..<channelList.count {
            let urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(channelList[index])&key=\(apiKey)"

            Alamofire.request(urlString).responseJSON { (response) in
                let channelJSON = JSON(response.result.value!)
                for item in channelJSON["items"] {

                    // Create a new dictionary to store only the values we care about.
                    var desiredValuesDict: [String: String] = [String: String]()
                    desiredValuesDict["title"] = item.1["snippet"]["title"].stringValue
                    desiredValuesDict["description"] = item.1["snippet"]["description"].stringValue
                    desiredValuesDict["thumbnail"] = item.1["snippet"]["thumbnails"]["default"]["url"].stringValue
                    desiredValuesDict["id"] = item.1["id"].stringValue

                    // Append the desiredValuesDict dictionary to the following array.
                    StudyDataStruct.channelsDataArray.append(desiredValuesDict as [String : String])
                    print("channel : \(item.1["snippet"]["title"].stringValue)")
                }
            }
        }
    }

}
