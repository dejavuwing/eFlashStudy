//
//  LoadData.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 4. 5..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation
import SwiftyJSON

// json 파일에 있는 데이터를 카테고리별로 담는다.
struct StudyDataStruct {
    static var words = [FSProtocal]()
    static var patterns = [FSProtocal]()
    static var dialogues = [FSProtocal]()
    static var ebs = [FSProtocal]()
}

class LoadData {

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
                    let flashData: FSProtocal = FSStruct(title: jsonData.1["title"].stringValue, means: jsonData.1["means"].stringValue, explains: jsonData.1["explains"].stringValue)

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

    /// FlashCategory로 Json 파일 이름을 확인한다.
    static func categoryToJsonFileName(category: FlashCategory) -> String {
        var returnValue: String = ""

        switch category {
        case .word: returnValue = "flashstudy_words"
        case .pattern: returnValue = "flashstudy_patterns"
        case .dialogue: returnValue = "flashstudy_dialogues"
        case .ebs: returnValue = "flashstudy_ebs"
        }

        return returnValue
    }
}
