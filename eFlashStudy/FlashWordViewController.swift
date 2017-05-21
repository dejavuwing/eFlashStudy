//
//  FlashWordViewController.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 5. 16..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import UIKit

enum FlashViewState {
    case word
    case means
    case explains
}

class FlashWordViewController: UIViewController {

    @IBOutlet weak var flashTextView: UITextView!

    var category: FlashCategory = .word

    var flashTimer: Timer?
    var eFlashStudyData = [FSProtocal]()
    var flashState: FlashViewState = .word
    var index: Int = 0
    var isPlay: Bool = true

    var strCurrentSecond = String()
    var douCurrentSecond: Double = 3.0

    override func viewDidLoad() {
        super.viewDidLoad()

        flashTextView.isUserInteractionEnabled = true
        flashTextView.isSelectable = false
        flashTextView.showsVerticalScrollIndicator = false

        if category == .word {
            eFlashStudyData = StudyDataStruct.words
        } else if category == .pattern {
            eFlashStudyData = StudyDataStruct.patterns
        }

        self.showFlashWord()

        strCurrentSecond = RealManager.getAppSetting(key: .flashSecond)
        douCurrentSecond = (strCurrentSecond as NSString).doubleValue

        // 네비게이션바 아이템(버튼) 처리
        let stopButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(stopFlashWord))
        navigationItem.rightBarButtonItem = stopButton

        flashTimer = Timer.scheduledTimer(timeInterval: douCurrentSecond, target: self, selector: #selector(showFlashWord), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func stopFlashWord() {

        if isPlay {
            // Timer를 처리에 대해 나중에 확인 하자 (stop아 이닌 진짜 pause가 있는지 확인)
            flashTimer?.invalidate()
            flashTimer = nil
            isPlay = false

            // 네비게이션바 아이템(버튼) 처리
            let playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.play, target: self, action: #selector(stopFlashWord))
            navigationItem.rightBarButtonItem = playButton

        } else {
            showFlashWord()
            flashTimer = Timer.scheduledTimer(timeInterval: douCurrentSecond, target: self, selector: #selector(showFlashWord), userInfo: nil, repeats: true)
            isPlay = true

            // 네비게이션바 아이템(버튼) 처리
            let playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(stopFlashWord))
            navigationItem.rightBarButtonItem = playButton
        }
    }

    // flashViewState에 따라 보여지는 텍스트를 다르게 한다.
    func showFlashWord() {
        var flashtext = String()

        if flashState == .word {
            index = RandomIndex.getIndex(maxNum: UInt32(eFlashStudyData.count))
        }

        // 텍스트 스타일(StringStyle)을 받아온다.
        let textViewStyle = TextStyle.stringStyle(category: .flashword)
        let contentText = getContentText(index: index)
        let titleXml = "<title>\(contentText.title)</title> \r\r"
        let meansXml = "<mean>\(self.markAccent(meansText: contentText.means))</mean> \r\r"
        let explainsXml = "<mean>\(self.markAccent(meansText: contentText.explains))</mean> \r\r"

        if flashState == .word {
            flashtext = titleXml
            flashState = .means

        } else if flashState == .means {
            flashtext = titleXml + meansXml

            if contentText.explains == "" {
                flashState = .word
            } else {
                flashState = .explains
            }

        } else if flashState == .explains {
            flashtext = titleXml + explainsXml
            flashState = .word
        }

        let attributedString = flashtext.styled(with: textViewStyle)
        flashTextView.attributedText = attributedString
    }

    /// actionType이 reverse일 경우 explains와 means를 바꿔서 리턴한다.
    func getContentText(index: Int) -> (title: String, explains: String, means: String) {
        let returnTitle = eFlashStudyData[index].title
        let returnExplains = eFlashStudyData[index].explains.replacingOccurrences(of: "\\n", with: "\r\r")
        let returnMeans = eFlashStudyData[index].means.replacingOccurrences(of: "\\n", with: "\r")

        return (returnTitle, returnExplains, returnMeans)
    }

    // 발음기호 Accent
    func markAccent(meansText: String) -> String {
        let accent: Character = "^"
        var newMeansText = meansText

        // 강세 찾기
        if let index = newMeansText.indexDistance(of: accent) {
            let accentIndex = newMeansText.characters.index(newMeansText.startIndex, offsetBy: index)
            let replaceIndex = newMeansText.characters.index(newMeansText.startIndex, offsetBy: index + 2)

            newMeansText.insert(contentsOf: "</accent>".characters, at: replaceIndex)
            newMeansText.remove(at: accentIndex)
            newMeansText.insert(contentsOf: "<accent>".characters, at: accentIndex)

            return newMeansText
        }

        return meansText
    }
}
