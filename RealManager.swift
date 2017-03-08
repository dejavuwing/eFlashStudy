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

    static func addReadHistory(category: FlashCategory, title: String, index: Int) {

        let realm = try! Realm()
        let readHistory = ReadHistory()

        readHistory.readTime = NSDate()
        readHistory.readCategory = flashCategoryToString(category: category)
        readHistory.readTitle = title
        readHistory.readIndex = index

        try! realm.write {
            realm.add(readHistory)
        }
    }

    // readTime을 기준으로 한단계 뒤의 데이터를 전달한다.
    static func getBackToCurrentIndex(category: FlashCategory, readTime: NSDate) -> (readTime: NSDate, readIndex: Int) {

        var returnTime = NSDate()
        var returnIndex = -1

        let realm = try! Realm()
        let readCategory = flashCategoryToString(category: category)

        let predicate = NSPredicate(format: "readTime < %@ and readCategory = %@", readTime, readCategory)
        let result = realm.objects(ReadHistory.self).filter(predicate).sorted(byKeyPath: "readTime", ascending: false)

        if result.endIndex != 0 {
            returnTime = result[0].readTime
            returnIndex = result[0].readIndex
        }

        return (returnTime, returnIndex)
    }

    // readTime을 기준으로 한단계 앞의 데이터를 전달한다.
    static func getForwardTocurrentIndex(category: FlashCategory, readTime: NSDate) -> (readTime: NSDate, readIndex: Int) {

        var returnTime = NSDate()
        var returnIndex = -1

        let realm = try! Realm()
        let readCategory = flashCategoryToString(category: category)

        let predicate = NSPredicate(format: "readTime > %@ and readCategory = %@", readTime, readCategory)
        let result = realm.objects(ReadHistory.self).filter(predicate).sorted(byKeyPath: "readTime", ascending: true)

        if result.endIndex != 0 {
            returnTime = result[0].readTime
            returnIndex = result[0].readIndex
        }

        return (returnTime, returnIndex)
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

    static func getContentReadCount(title: String) -> Int {

        let realm = try! Realm()
        let predicate = NSPredicate(format: "readTitle = %@", title)
        let result = realm.objects(ContentReadCount.self).filter(predicate)

        return result[0].readCount
    }

    




}
