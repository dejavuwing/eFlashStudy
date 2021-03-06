//
//  FlashStudyData.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 3. 6..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation
import RealmSwift

// 하루 단위로 카테고리별 읽은 수를 저장한다.
class FlashStudyData: Object {

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

// 시간 단위로 읽은 정보를 저장한다.
class ReadHistory: Object {

    dynamic var readTime: NSDate = NSDate() // 읽은 날짜와 시간
    dynamic var readCategory: String = ""   // 읽은 카테고리
    dynamic var readTitle: String = ""      // 해당 내용의 title
    dynamic var readIndex: Int = 0          // 해당 내용의 Json index
    dynamic var historyIndex: Int = 0       // 해당 카테고리에서의 읽은 순서

    override static func indexedProperties() -> [String] {
        return ["readTime"]
    }
}

// Title에 대한 읽은 수를 기록한다.
class ContentReadCount: Object {

    dynamic var readTitle = ""
    dynamic var readCount = 0

    override static func primaryKey() -> String? {
        return "readTitle"
    }
}

// 앱 설정 정보를 관리한다.
class AppSettings: Object {

    dynamic var setKey: String = ""
    dynamic var setValue: String = ""

    override static func primaryKey() -> String {
        return "setKey"
    }
}
