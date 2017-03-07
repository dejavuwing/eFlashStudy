//
//  ViewController.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 3. 3..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import UIKit
import SwiftyJSON
import BonMot
import EZLoadingActivity

protocol FSProtocal {
    var title: String {get set}
    var means: String {get set}
    var explains: String {get set}
}

struct FSStruct: FSProtocal {
    var title: String
    var means: String
    var explains: String
}

enum FlashCategory {
    case word
    case dialogue
    case pattern
    case ebs
}

class ViewController: UIViewController {

    @IBOutlet weak var flashTextView: UITextView!
    @IBOutlet weak var toolbar: UIToolbar!

    var eFlashStudyData = [FSProtocal]()
    var isHide = true
    var currentIndex: Int = 0

    var toDay = ""
    var readCategory: FlashCategory = .word

    override func viewDidLoad() {
        super.viewDidLoad()

        // realm 기록을 위한 오늘 날짜 확인
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        toDay = formatter.string(from: currentDateTime)

        flashTextView.text = "Loading..."
        flashTextView.isUserInteractionEnabled = true
        flashTextView.isSelectable = false
        flashTextView.showsVerticalScrollIndicator = false

        isHide = true

        // TapGesture를 meanTextView에 연결한다. (화면을 탭했을 때의 액션 처리)
        let tap = UITapGestureRecognizer(target: self, action: #selector(showFlashForSelector))
        tap.numberOfTapsRequired = 2
        self.flashTextView.addGestureRecognizer(tap)

        // PList의 eFlashStudyRecentJsonFile 정보 확인 (가장 마지막에 로드한 JSON 파일 네임 확인)
        if let jsonFileName = PlistManager.sharedInstance.getValueForKey(key: "eFlashStudyRecentJsonFile") as? String {
            if self.loadJsonData(jsonFileName: jsonFileName) {

                // 카테고리 지정
                if jsonFileName == "flashstudy_words" {
                    readCategory = .word
                } else if jsonFileName == "flashstudy_dialogues" {
                    readCategory = .dialogue
                } else if jsonFileName == "flashstudy_patterns" {
                    readCategory = .pattern
                } else if jsonFileName == "flashstudy_ebs" {
                    readCategory = .ebs
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.showFlash(withIndex: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // json 파일 데이터를 변수에 담는다.
    func loadJsonData(jsonFileName: String) -> Bool {

        let jsonFileUrl = Bundle.main.url(forResource: jsonFileName, withExtension: "json")!
        let wordsData = try? String(contentsOf: jsonFileUrl, encoding: String.Encoding.utf8)

        if let dataFromString = wordsData?.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)

            for jsonData in json["voca"] {
                let flashData: FSProtocal = FSStruct(title: jsonData.1["title"].stringValue, means: jsonData.1["means"].stringValue, explains: jsonData.1["explains"].stringValue)
                eFlashStudyData.append(flashData)
            }
            return true
        } else {
            return false
        }
    }

    // Return Random Int
    func randomInt(maxNum: UInt32) -> Int {
        let randomNum: UInt32 = arc4random_uniform(maxNum)
        return Int(randomNum)
    }

    // 단어를 보여준다. (for Tap Selector)
    func showFlashForSelector() {
        showFlash(withIndex: nil)
        isHide = true
    }

    // 단어를 보여준다.
    func showFlash(withIndex: Int?) {
        var index: Int = 0

        if withIndex == nil {
            index = randomInt(maxNum: UInt32(eFlashStudyData.count))
            currentIndex = index
        } else {
            index = withIndex!
        }

        if eFlashStudyData[index].explains == "" {
            self.showFlash(withIndex: nil)

        } else {
            let titleStyle = StringStyle(.font(UIFont(name: "Helvetica-Bold", size: 18.0)!))
            let explainStyle = StringStyle(.font(UIFont(name: "Helvetica-Light", size: 16.0)!))
            let meanStyle = StringStyle(.font(UIFont(name: "Helvetica-Light", size: 16.0)!))
            let accentStyle = StringStyle(.font(UIFont(name: "Helvetica-Bold", size: 17.0)!))

            let textViewStyle = StringStyle(
                .font(UIFont.systemFont(ofSize: 16)),
                .lineHeightMultiple(1.2),
                .color(.black),
                .xmlRules([
                    .style("title", titleStyle),
                    .style("explain", explainStyle),
                    .style("mean", meanStyle),
                    .style("accent", accentStyle)
                    ])
            )

            let titleText = "<title>\(eFlashStudyData[index].title)</title> \r\r"
            let explainsText = "<mean>\(eFlashStudyData[index].explains.replacingOccurrences(of: "\\n", with: "\r\r"))</mean> \r\r"
            var flashtext = titleText + explainsText

            if withIndex != nil {
                let meansText = "<mean>\(eFlashStudyData[index].means.replacingOccurrences(of: "\\n", with: "\r"))</mean>"
                let newMeansText = markAccent(meansText: meansText)

                flashtext.append(newMeansText)
            }

            let attributedString = flashtext.styled(with: textViewStyle)
            flashTextView.attributedText = attributedString
        }

        // 읽은 카운트를 기록한다.
        let readCount = RealManager.addStudyCount(toDay: toDay, category: readCategory)
        print(readCount)

        // 이벤트 카운트 Alert를 확인한다.
        EventAlert.eventCountAlert(fromController: self, readCount: readCount, category: readCategory)
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

    // eFlashStudyData를 초기화한다.
    func reloadView(jsonFileName: String) {
        eFlashStudyData = [FSProtocal]()
        PlistManager.sharedInstance.saveValue(value: jsonFileName as AnyObject, forKey: "eFlashStudyRecentJsonFile")

        self.viewDidLoad()
        self.showFlash(withIndex: nil)
    }

    @IBAction func selectCategory(_ sender: Any) {

        let alertController = UIAlertController(title: nil, message: "[Select Category]", preferredStyle: .actionSheet)

        let loadCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        })

        let loadWords = UIAlertAction(title: "Words", style: .default, handler: { (_) in
            self.reloadView(jsonFileName: "flashstudy_words")
        })

        let loadPatterns = UIAlertAction(title: "Patterns", style: .default, handler: { (_) in
            self.reloadView(jsonFileName: "flashstudy_patterns")
        })

        let loadDialogues = UIAlertAction(title: "Dialogues", style: .default, handler: { (_) in
            self.reloadView(jsonFileName: "flashstudy_dialogues")
        })

        let loadEBS = UIAlertAction(title: "EBS", style: .default, handler: { (_) in
            self.reloadView(jsonFileName: "flashstudy_ebs")
        })

        alertController.addAction(loadCancel)
        alertController.addAction(loadWords)
        alertController.addAction(loadPatterns)
        alertController.addAction(loadDialogues)
        alertController.addAction(loadEBS)

        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.barButtonItem = sender as? UIBarButtonItem
            }
        }

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func pauseResume(_ sender: Any) {

        if isHide {
            self.showFlash(withIndex: currentIndex)
            isHide = false
        } else {
            self.showFlash(withIndex: nil)
            isHide = true
        }
    }
}

extension String {
    func indexDistance(of character: Character) -> Int? {
        guard let index = characters.index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
