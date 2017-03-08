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

    // 하루 단위로 카테고리별 읽은 수를 저장한다.
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

class ReadHistory: Object {

    // 시간 단위로 읽은 정보를 저장한다.
    dynamic var readTime = NSDate()
    dynamic var readCategory = ""
    dynamic var readTitle = ""
    dynamic var readIndex = 0

    override static func indexedProperties() -> [String] {
        return ["readTime"]
    }
}

class ContentReadCount: Object {

    // Title에 대한 읽은 수를 기록한다.
    dynamic var readTitle = ""
    dynamic var readCount = 0

    override static func primaryKey() -> String? {
        return "readTitle"
    }
}

