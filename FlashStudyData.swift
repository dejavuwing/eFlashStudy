//
//  FlashStudyData.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 3. 6..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation
import RealmSwift

class FlashStudyData: Object {

    // 하루 동안 읽은 수 확인
    dynamic var studyDate = ""
    dynamic var readTotalCount = 0
    dynamic var readCountWord = 0
    dynamic var readCountDialogue = 0
    dynamic var readCountPattern = 0
    dynamic var readCountEBS = 0

    override static func indexedProperties() -> [String] {
        return ["studyDate"]
    }

    override static func primaryKey() -> String? {
        return "studyDate"
    }
}
