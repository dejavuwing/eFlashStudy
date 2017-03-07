//
//  EventAlert.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 3. 7..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation
import UIKit

class EventAlert {

    static func eventCountAlert(fromController controller: UIViewController, readCount: Int, category: FlashCategory) {

        let eventCount = getEventCount(readCount: readCount, category: category)
        if eventCount.result {
            let alertController = UIAlertController(title: eventCount.title, message: eventCount.notice, preferredStyle: .alert)
            let alertOK = UIAlertAction(title: "OK", style: .default) { (_) in
            }

            alertController.addAction(alertOK)
            controller.present(alertController, animated: true, completion: nil)
        }
    }

    static func getEventCount(readCount: Int, category: FlashCategory) -> (result: Bool, title: String, notice: String) {

        var setResult = false
        var setTitle = ""
        var setNotice = ""

        let eventCount = [10, 20, 50, 100, 200]
        if eventCount.contains(readCount) {
            setResult = true

            if readCount == 10 {
                setNotice = "소리내서 잘 읽으셨나요?"
            } else if readCount == 20 {
                setNotice = "잘하고 있습니다.\n조금만 더 집중해서 읽으세요."
            } else if readCount == 50 {
                setNotice = "오늘 목표는 체웠습니다.\n더 읽어보시겠어요?"
            } else if readCount == 100 {
                setNotice = "입에 착착 붙나보네요.\n이제 마무리 하셔도 됨니다."
            } else if readCount == 200 {
                setNotice = "정말 읽으신거 맞나요?\n대단합니다."
            }

            if category == .dialogue {
                setTitle = "다이얼로그 읽기 \(readCount) 번 !"
            } else if category == .ebs {
                setTitle = "EBS 교제 읽기 \(readCount) 번 !"
            } else if category == .pattern {
                setTitle = "영어 패턴 읽기 \(readCount) 번 !"
            } else if category == .word {
                setTitle = "영어 단어 읽기 \(readCount) 번 !"
            }
        }

        return (setResult, setTitle, setNotice)
    }

}
