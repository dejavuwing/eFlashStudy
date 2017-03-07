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

        print("\(studyCount)")

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

}
