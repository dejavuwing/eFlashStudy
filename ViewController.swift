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

enum ShowContentAction {
    case new
    case hideMeans
    case showMeans
    case back
    case forward
    case reverse
}

class ViewController: UIViewController {

    @IBOutlet weak var flashTextView: UITextView!
    @IBOutlet weak var toolbar: UIToolbar!

    var eFlashStudyData = [FSProtocal]()
    var currentIndex: Int = 0
    var hideMeans = true
    var reverse = false

    var toDay = ""
    var readCategory: FlashCategory = .word

    var currentTime = NSDate()
    var backReadtime = NSDate()

    override func viewDidLoad() {
        super.viewDidLoad()

        // TapGesture를 meanTextView에 연결한다. (화면을 2번 탭했을 때의 액션 처리)
        let twoTap = UITapGestureRecognizer(target: self, action: #selector(reverseMeansToExplains))
        twoTap.numberOfTapsRequired = 2
        self.flashTextView.addGestureRecognizer(twoTap)

        // SwipeGesture (왼쪽으로 밀기)를 이용해 새로운 컨텐츠 보이기
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(forwardContent))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.flashTextView.addGestureRecognizer(swipeLeft)

        // SwipeGesture (오른쪽으로 밀기)를 이용해 이전 컨텐츠 보이기
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(backContent))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.flashTextView.addGestureRecognizer(swipeRight)

        // realm 기록을 위한 오늘 날짜 확인
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        toDay = formatter.string(from: currentDateTime)

        flashTextView.text = "Loading..."
        flashTextView.isUserInteractionEnabled = true
        flashTextView.isSelectable = false
        flashTextView.showsVerticalScrollIndicator = false

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
        self.showFlash(actionType: .new, withIndex: nil)
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

    // 새로운 내용을 보여준다. (for Tap Selector)
    func newContent() {
        showFlash(actionType: .new, withIndex: nil)
    }

    func forwardContent() {

        let forwardIndex = RealManager.getForwardTocurrentIndex(category: readCategory, readTime: currentTime)

        // -1이 리턴된 경우 새로운 내용을 보여준다.
        if forwardIndex.readIndex == -1 {
            self.showFlash(actionType: .new, withIndex: nil)
            
        } else {
            if currentIndex == forwardIndex.readIndex {
                currentTime = NSDate()
                forwardContent()

            } else {
                currentTime = forwardIndex.readTime
                currentIndex = forwardIndex.readIndex
                self.showFlash(actionType: .forward, withIndex: currentIndex)
            }
        }
    }

    // 같은 카테고리에서 뒤로 가기
    func backContent() {

        let backIndex = RealManager.getBackToCurrentIndex(category: readCategory, readTime: currentTime)

        // -1이 리턴된 경우 현재 내용을 그대로 보여준다. (아무 반응을 하지 않는다.)
        if backIndex.readIndex == -1 {
            print("마지막 페이지 입니다.")

        } else {
            currentTime = backIndex.readTime
            currentIndex = backIndex.readIndex
            self.showFlash(actionType: .back, withIndex: currentIndex)
        }
    }

    // 새로운 내용을 보여준다. (3가지의 Action으로 구분)
    func showFlash(actionType: ShowContentAction, withIndex: Int?) {

        var index: Int = 0

        // 넘어온 인덱스가 nil이라면 새로 받는다.
        if withIndex == nil {
            index = randomInt(maxNum: UInt32(eFlashStudyData.count))
            currentIndex = index
        } else {
            index = withIndex!
        }

        if eFlashStudyData[index].explains == "" {
            self.showFlash(actionType: actionType, withIndex: nil)

        } else {
            // 텍스트 스타일(StringStyle)을 받아온다.
            let textViewStyle = TextStyle.stringStyle(category: readCategory)

            let contentText = getContentText(actionType: actionType, index: index)
            let titleXml = "<title>\(contentText.title)</title> \r\r"
            let explainsXml = "<mean>\(contentText.explains)</mean> \r\r"
            let meansMxl = "<mean>\(contentText.means)</mean>"
            var flashtext = titleXml + explainsXml

            if actionType == .showMeans {

                let newMeansText = markAccent(meansText: meansMxl)
                flashtext.append(newMeansText)
            }

            if actionType == .new {

                // 읽은 카운트를 기록한다.
                let readCount = RealManager.addStudyCount(toDay: toDay, category: readCategory)

                // 이벤트 카운트 Alert를 확인한다.
                EventAlert.eventCountAlert(fromController: self, readCount: readCount, category: readCategory)

                // 읽기 히스토리를 기록한다.
                RealManager.addReadHistory(category: readCategory, title: contentText.title, index: currentIndex)

                // 컨텐츠별 읽은 수를 기록한다.
                RealManager.addContentReadCount(title: contentText.title)
            }

            let attributedString = flashtext.styled(with: textViewStyle)
            flashTextView.attributedText = attributedString
        }
    }

    // actionType이 reverse일 경우 explains와 means를 바꿔서 리턴한다.
    func getContentText(actionType: ShowContentAction, index: Int) -> (title: String, explains: String, means: String) {

        var returnTitle = ""
        var returnExplains = ""
        var returnMeans = ""

        if actionType == .reverse {
            returnTitle = eFlashStudyData[index].title
            returnExplains = eFlashStudyData[index].means.replacingOccurrences(of: "\\n", with: "\r\r")
            returnMeans = eFlashStudyData[index].explains.replacingOccurrences(of: "\\n", with: "\r\r")
        } else {
            returnTitle = eFlashStudyData[index].title
            returnExplains = eFlashStudyData[index].explains.replacingOccurrences(of: "\\n", with: "\r\r")
            returnMeans = eFlashStudyData[index].means.replacingOccurrences(of: "\\n", with: "\r\r")
        }

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

    // eFlashStudyData를 초기화한다.
    func reloadView(jsonFileName: String) {
        eFlashStudyData = [FSProtocal]()
        PlistManager.sharedInstance.saveValue(value: jsonFileName as AnyObject, forKey: "eFlashStudyRecentJsonFile")

        self.viewDidLoad()
        self.showFlash(actionType: .new, withIndex: nil)
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

    func reverseMeansToExplains() {
        if reverse {
            self.showFlash(actionType: .hideMeans, withIndex: currentIndex)
            reverse = false

        } else {
            self.showFlash(actionType: .reverse, withIndex: currentIndex)
            reverse = true
        }
    }

    func startStudyForRealmInit() {
        let alertController = UIAlertController(title: "영어 읽기를 시작하시겠습니까?", message: "오늘 읽은 횟수와 히스토리 정보가 삭제됩니다.", preferredStyle: .alert)

        let startOk = UIAlertAction(title: "OK", style: .default) { (_) in
            RealManager.initTodaysStudyCount(toDay: self.toDay)
            RealManager.initReadHistory()
            EventAlert.alertWithOk(fromController: self, setTitle: "이제 소리내서 읽어보세요.", setNotice: "읽은 횟수와 히스토리가 삭제되었습니다.")
        }

        let startCancle = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }

        alertController.addAction(startOk)
        alertController.addAction(startCancle)

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func reverseMeans(_ sender: Any) {

        let alertController = UIAlertController(title: nil, message: "[Select Category]", preferredStyle: .actionSheet)

        let infoCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        })

        let infoStudyStart = UIAlertAction(title: "Start Study", style: .default, handler: { (_) in
            self.startStudyForRealmInit()
        })

        alertController.addAction(infoCancel)
        alertController.addAction(infoStudyStart)

        if UI_USER_INTERFACE_IDIOM() == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.barButtonItem = sender as? UIBarButtonItem
            }
        }

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func pauseResume(_ sender: Any) {
        if hideMeans {

            // 현재 보이지 않고 있다면 뜻을 보여준다.
            self.showFlash(actionType: .showMeans, withIndex: currentIndex)
            hideMeans = false

        } else {

            // 현재 보이고 있다면 뜻을 숨긴다.
            self.showFlash(actionType: .hideMeans, withIndex: currentIndex)
            hideMeans = true
        }
    }
}

extension String {
    func indexDistance(of character: Character) -> Int? {
        guard let index = characters.index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
