//
//  RealManager.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 3. 6..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation
import RealmSwift

class RealManager {

    static func existCountDate(toDay: String) -> Bool {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "studyDate = %@", toDay)
        let result = realm.objects(FlashStudyData.self).filter(predicate)

        if result.count == 0 {
            return false
        } else {
            return true
        }
    }

    static func todayInit(toDay: String) {
        let realm = try! Realm()
        let studyCount = FlashStudyData()
        studyCount.studyDate = toDay

        if !existCountDate(toDay: toDay) {
            try! realm.write {
                realm.add(studyCount)
            }
        }
    }

    static func addStudyCount(toDay: String, category: FlashCategory) -> Int {
        var returnCount = 0

        todayInit(toDay: toDay)

        let realm = try! Realm()
        let predicate = NSPredicate(format: "studyDate = %@", toDay)
        let result = realm.objects(FlashStudyData.self).filter(predicate)

        let studyCount = FlashStudyData()
        studyCount.studyDate = toDay
        studyCount.readTotalCount = result[0].readTotalCount + 1

        if category == .dialogue {
            studyCount.readCountDialogue = result[0].readCountDialogue + 1
            returnCount = result[0].readCountDialogue + 1
        } else {
            studyCount.readCountDialogue = result[0].readCountDialogue
        }

        if category == .ebs {
            studyCount.readCountEBS = result[0].readCountEBS + 1
            returnCount = result[0].readCountEBS + 1
        } else {
            studyCount.readCountEBS = result[0].readCountEBS
        }

        if category == .pattern {
            studyCount.readCountPattern = result[0].readCountPattern + 1
            returnCount = result[0].readCountPattern + 1
        } else {
            studyCount.readCountPattern = result[0].readCountPattern
        }

        if category == .word {
            studyCount.readCountWord = result[0].readCountWord + 1
            returnCount = result[0].readCountWord + 1
        } else {
            studyCount.readCountWord = result[0].readCountWord
        }

        if existCountDate(toDay: toDay) {
            try! realm.write {
                realm.add(studyCount, update: true)
            }
        } else {
            try! realm.write {
                realm.add(studyCount)
            }
        }

        return returnCount
    }

    /// 오늘 읽은 수를 초기화 한다.
    static func initTodaysStudyCount(toDay: String) {

        todayInit(toDay: toDay)

        let realm = try! Realm()

        let studyCount = FlashStudyData()
        studyCount.studyDate = toDay
        studyCount.readTotalCount = 0
        studyCount.readCountEBS = 0
        studyCount.readCountWord = 0
        studyCount.readCountDialogue = 0
        studyCount.readCountPattern = 0

        try! realm.write {
            realm.add(studyCount, update: true)
        }
    }

    /// ReadHistory 데이터를 지운다. (초기화)
    static func initReadHistory() {
        let realm = try! Realm()
        let result = realm.objects(ReadHistory.self)

        try! realm.write {
            realm.delete(result)
        }
    }

    /// 읽은 내용을 기록한다.
    static func addReadHistory(category: FlashCategory, title: String, index: Int) {
        let realm = try! Realm()
        let readHistory = ReadHistory()

        let readCategory = flashCategoryToString(category: category)
        let predicate = NSPredicate(format: "readCategory = %@", readCategory)
        let maxHistoryIndex = (realm.objects(ReadHistory.self).filter(predicate).max(ofProperty: "historyIndex") as Int? ?? 0) + 1

        readHistory.readTime = NSDate()
        readHistory.readCategory = readCategory
        readHistory.readTitle = title
        readHistory.readIndex = index
        readHistory.historyIndex = maxHistoryIndex

        try! realm.write {
            realm.add(readHistory)
        }
    }

    /// ReadHistory의 historyIndex를 반환한다.
    static func getHistoryIndexFromReadHistory(category: FlashCategory, index: Int) -> Int {
        let realm = try! Realm()
        let readCategory = flashCategoryToString(category: category)
        let predicate = NSPredicate(format: "readCategory = %@ and readIndex == %i", readCategory, index)
        let readHistory = realm.objects(ReadHistory.self).filter(predicate)

        return readHistory[0].historyIndex
    }

    /**
    ReadHistory의 readTime을 기준으로 데이터를 전달한다.

     - parameters:
        - category: FlashCategory
        - readTime: readTime
        - isForward: true라면 한단계 앞의 데이터를, false라면 한단계 뒤의 데이터를 불러온다.
    */
    static func getCurrentIndex(category: FlashCategory, readTime: NSDate, isForward: Bool) -> (readTime: NSDate, readIndex: Int, readHistoryIndex: Int) {
        var returnTime = NSDate()
        var returnIndex: Int = -1
        var returnHistoryIndex: Int = 1

        let realm = try! Realm()
        let readCategory = flashCategoryToString(category: category)
        var predicate = NSPredicate()

        if isForward {
            // 현재 보고있는 페이지보다 이후 시간의 데이터 불러오기
            predicate = NSPredicate(format: "readTime > %@ and readCategory = %@", readTime, readCategory)
        } else {
            // 현재 보고있는 페이지보다 이전 시간의 데이터 불러오기
            predicate = NSPredicate(format: "readTime < %@ and readCategory = %@", readTime, readCategory)
        }

        let result = realm.objects(ReadHistory.self).filter(predicate).sorted(byKeyPath: "readTime", ascending: isForward)

        if result.endIndex > 0 {
            returnTime = result[0].readTime
            returnIndex = result[0].readIndex
            returnHistoryIndex = result[0].historyIndex
        }

        return (returnTime, returnIndex, returnHistoryIndex)
    }

    /// ReadHistory에 기록된 Index인지 확인한다.
    static func isReadHistory(category: FlashCategory, readIndex: Int) -> Bool {
        let realm = try! Realm()
        let readCategory = flashCategoryToString(category: category)
        let predicate = NSPredicate(format: "readCategory = %@ and readIndex == %i", readCategory, readIndex)
        let result = realm.objects(ReadHistory.self).filter(predicate)

        if result.endIndex > 0 {
            return true
        } else {
            return false
        }
    }

    static func flashCategoryToString(category: FlashCategory) -> String {
        var reaturnValue = ""

        if category == .dialogue {
            reaturnValue = "dialogue"
        } else if category == .ebs {
            reaturnValue = "ebs"
        } else if category == .pattern {
            reaturnValue = "pattern"
        } else if category == .word {
            reaturnValue = "word"
        }

        return reaturnValue
    }

    /// ContentReadCount에 Title에 대한 읽은 수를 기록한다.
    static func addContentReadCount(title: String) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "readTitle = %@", title)
        let result = realm.objects(ContentReadCount.self).filter(predicate)

        let contentReadCount = ContentReadCount()

        if result.endIndex == 0 {
            contentReadCount.readTitle = title
            contentReadCount.readCount = 1
        } else {
            contentReadCount.readTitle = title
            contentReadCount.readCount = result[0].readCount + 1
        }

        try! realm.write {
            realm.add(contentReadCount, update: true)
        }
    }

    /// Title에 대한 총 읽은 수를 return 한다.
    static func getContentReadCount(title: String) -> Int {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "readTitle = %@", title)
        let result = realm.objects(ContentReadCount.self).filter(predicate)

        return result[0].readCount
    }

    // MARK: - appSettings (앱 설정)

    /// SettingKey를 String으로 가져온다.
    static func settingKeyToString(key: SettingKey) -> String {
        var reaturnValue = ""

        if key == .recentCategory {
            reaturnValue = "recentCategory"
        } else if key == .pushPattern {
            reaturnValue = "pushPattern"
        } else if key == .flashSecond {
            reaturnValue = "flashSecond"
        }

        return reaturnValue
    }

    /// 앱 설정값을 기록한다.
    static func setAppSetting(key: SettingKey, value: String) {
        let realm = try! Realm()
        let appSettings = AppSettings()

        appSettings.setKey = settingKeyToString(key: key)
        appSettings.setValue = value

        try! realm.write {
            realm.add(appSettings, update: true)
        }
    }

    /// 앱 설정값을 불러온다.
    static func getAppSetting(key: SettingKey) -> String {
        let realm = try! Realm()
        let setKey: String = settingKeyToString(key: key)

        let predicate = NSPredicate(format: "setKey = %@", setKey)
        let result = realm.objects(AppSettings.self).filter(predicate)

        return result[0].setValue
    }

    // 앱 설정값이 있는지 확인한다.
    static func existAppSetting(key: SettingKey) -> Bool {
        let realm = try! Realm()
        let setKey: String = settingKeyToString(key: key)

        let predicate = NSPredicate(format: "setKey = %@", setKey)
        let result = realm.objects(AppSettings.self).filter(predicate)

        if result.count == 0 {
            return false
        } else {
            return true
        }
    }

    /// 앱 기본 옵션값을 등록한다.
    /**
        .recentCategory: dialogue
        .pushPattern: YES
        .flashSecond: 3.0
    */
    static func setDefaultOption() {

        // 초기 Category 기록
        if !RealManager.existAppSetting(key: .recentCategory) {
            RealManager.setAppSetting(key: .recentCategory, value: "dialogue")
        }

        // 푸시 알림 설정 기록
        if !RealManager.existAppSetting(key: .pushPattern) {
            RealManager.setAppSetting(key: .pushPattern, value: "YES")
        }

        // Flash Word 기본 속도 기록
        if !RealManager.existAppSetting(key: .flashSecond) {
            RealManager.setAppSetting(key: .flashSecond, value: "3")
        }
    }

}
