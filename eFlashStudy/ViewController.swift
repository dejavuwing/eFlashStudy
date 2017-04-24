//
//  ViewController.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 3. 3..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import Foundation
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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

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
    var pushTimer: Timer!

    // 검색 테이블 정의
    @IBOutlet weak var dimmedView: UIView!
    @IBOutlet weak var searchWordTable: UITableView!

    let searchController = UISearchController(searchResultsController: nil)
    var filteredWords = [FSProtocal]()

    // 검색 결과창 정의
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultDone: UIButton!
    @IBOutlet weak var resultWord: UITextView!

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

            // 우선 최적화는 나중에 하고
            // StudyDataStruct에 가지고 있는 데이터들을 카테고리에 맞게 eFlashStudyData에 다시 넣어준다.
            if jsonFileName == "flashstudy_words" {
                readCategory = .word
                eFlashStudyData = StudyDataStruct.words

            } else if jsonFileName == "flashstudy_dialogues" {
                readCategory = .dialogue
                eFlashStudyData = StudyDataStruct.dialogues

            } else if jsonFileName == "flashstudy_patterns" {
                readCategory = .pattern
                eFlashStudyData = StudyDataStruct.patterns

            } else if jsonFileName == "flashstudy_ebs" {
                readCategory = .ebs
                eFlashStudyData = StudyDataStruct.ebs
            }
        }

        // 검색 테이블 뷰 정의
        dimmedView.backgroundColor = UIColor.clear
        dimmedView.alpha = 0

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.layer.cornerRadius = 10
        searchController.searchBar.clipsToBounds = true
        searchController.searchBar.delegate = self

        searchWordTable.delegate = self
        searchWordTable.dataSource = self
        searchWordTable.layer.cornerRadius = 10
        searchWordTable.layer.masksToBounds = true
        searchWordTable.isHidden = true
        searchWordTable.tableHeaderView = searchController.searchBar

        definesPresentationContext = true

        // 검색 결과창 정의
        resultView.isHidden = true
        resultView.layer.cornerRadius = 10
        resultDone.layer.cornerRadius = 10
        resultWord.layer.cornerRadius = 10

        resultWord.isUserInteractionEnabled = true
        resultWord.isSelectable = false
        resultWord.showsVerticalScrollIndicator = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.showFlash(actionType: .new, withIndex: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // 키보드를 내린다.
    func dismissKeyboard() {
        view.endEditing(true)
    }

    /// ReadHistory에서 현재 readTime보다 이후 것을 보여준다.
    func forwardContent() {
        let forwardIndex = RealManager.getCurrentIndex(category: readCategory, readTime: currentTime, isForward: true)

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

    /// ReadHistory에서 현재 readTime보다 이전 것을 보여준다.
    func backContent() {
        let backIndex = RealManager.getCurrentIndex(category: readCategory, readTime: currentTime, isForward: false)

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

            index = RandomIndex.getIndex(maxNum: UInt32(eFlashStudyData.count))
            if RealManager.isReadHistory(category: readCategory, readIndex: index) {

                // index가 ReadHistory에 있다면 한번 더 받아온다. (RandomIndex에 대해서는 다음에 고도화 예정)
                index = RandomIndex.getIndex(maxNum: UInt32(eFlashStudyData.count))
            }

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
            let explainsXml = "<mean>\(self.markAccent(meansText: contentText.explains))</mean> \r\r"
            let flashtext = titleXml + explainsXml

            if actionType == .new {
                let readCount = RealManager.addStudyCount(toDay: toDay, category: readCategory)                     // 읽은 카운트를 기록한다.
                EventAlert.eventCountAlert(fromController: self, readCount: readCount, category: readCategory)      // 이벤트 카운트 Alert를 확인한다.
                RealManager.addReadHistory(category: readCategory, title: contentText.title, index: currentIndex)   // 읽기 히스토리를 기록한다.
                RealManager.addContentReadCount(title: contentText.title)                                           // 컨텐츠별 읽은 수를 기록한다.
            }

            let attributedString = flashtext.styled(with: textViewStyle)
            flashTextView.attributedText = attributedString
        }

        // 새로운 내용(.new)이거나 back, forward로 이동할 때만 ToastMessage를 보여준다.
        let toastViewCondition: [ShowContentAction] = [.new, .back, .forward]
        if toastViewCondition.contains(actionType) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let readTime = formatter.string(from: currentTime as Date)
            let historyIndex = RealManager.getHistoryIndexFromReadHistory(category: readCategory, index: currentIndex)
            let toastMessage: String = "\(historyIndex) (\(readTime))"
            view.makeToast(message: toastMessage)
        }
    }

    /// actionType이 reverse일 경우 explains와 means를 바꿔서 리턴한다.
    func getContentText(actionType: ShowContentAction, index: Int) -> (title: String, explains: String, means: String) {
        var returnTitle = ""
        var returnExplains = ""
        var returnMeans = ""

        // 내용과 뜻을 변환해서 보여준다.
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

    /// eFlashStudyData를 초기화한다.
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

        // EBS를 paragraph로 노출한다.
        let loadEBS = UIAlertAction(title: "Paragraph", style: .default, handler: { (_) in
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

    /// 내용과 뜻을 변환해서 보여준다.
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

    /// 단어 검색
    @IBAction func pauseResume(_ sender: Any) {

        // 단어 검색 테이블을 연다
        if searchWordTable.isHidden {
            dimmedView.alpha = 0.8
            dimmedView.backgroundColor = UIColor.gray

            // 검색 아이콘 눌렀을때 바로 Active 하게 해야 한다.
            // 그러나 Table cell이 맞지않을 경우 searchbar가 테이블뷰 위에 나오는 버그가 있음.
            // 해결하기 전까지 Active는 막아논다.
            //searchController.isActive = true

            searchWordTable.isHidden = false

            //let moveToIndexPath = IndexPath(row: 0, section: 0)

        } else {
            dimmedView.alpha = 0
            dimmedView.backgroundColor = UIColor.clear
            searchController.isActive = false
            searchWordTable.isHidden = true
            resultView.isHidden = true
        }
    }

    /// 영어 단어와 한글 뜻에서 검색어를 찾아 반환한다.
    func filterContentForSearchText(searchText: String) {
        filteredWords = StudyDataStruct.words.filter({ word in
            return word.title.lowercased().contains(searchText.lowercased()) || word.means.lowercased().contains(searchText.lowercased())
        })

        self.searchWordTable.reloadData()
    }

    // Section의 수를 확인한다.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // Section의 cell 수를 반환한다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredWords.count

        } else {
            return StudyDataStruct.words.count
        }
    }

    // Index에 해당하는 Row를 cell에 확인한다.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mySearchWordCell", for: indexPath as IndexPath)

        // 검색한 단어를 cell에 전달
        if searchController.isActive && searchController.searchBar.text != "" {
            let word = filteredWords[indexPath.row]
            cell.textLabel?.text = word.title

        } else {
            let row = indexPath.row
            cell.textLabel?.text = StudyDataStruct.words[row].title
        }

        return cell
    }

    // Table View Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

        // Cell을 선택했을때 키보드를 내린다.
        searchController.searchBar.endEditing(true)

        // 단어를 검색한다면 Section을 보여주지 않는다
        if searchController.isActive && searchController.searchBar.text != "" {
            setResultTextStyle(isSearch: true, indexRow: indexPath.row)

        } else {
            setResultTextStyle(isSearch: false, indexRow: indexPath.row)

        }
    }

    // 검색 내용에 대한 텍스트 처리
    func setResultTextStyle(isSearch: Bool, indexRow: Int) {
        //var title: String = ""
        //var means: String = ""
        //var explains: String = ""

        var title = String()
        var means = String()
        var explains = String()

        // 텍스트 스타일(StringStyle)을 받아온다.
        let textViewStyle = TextStyle.stringStyleForSearchResult()

        if isSearch {
            resultView.isHidden = false
            view.bringSubview(toFront: resultView)

            title = filteredWords[indexRow].title.replacingOccurrences(of: "\\n", with: "\r")
            means = filteredWords[indexRow].means.replacingOccurrences(of: "\\n", with: "\r")
            explains = filteredWords[indexRow].explains.replacingOccurrences(of: "\\n", with: "\r\r")

            print("Searched Item : \(filteredWords[indexRow].title)")

        } else {
            resultView.isHidden = false
            view.bringSubview(toFront: resultView)

            title = StudyDataStruct.words[indexRow].title.replacingOccurrences(of: "\\n", with: "\r")
            means = StudyDataStruct.words[indexRow].means.replacingOccurrences(of: "\\n", with: "\r")
            explains = StudyDataStruct.words[indexRow].explains.replacingOccurrences(of: "\\n", with: "\r\r")

            print("Listed Item : \(StudyDataStruct.words[indexRow].title)")
        }

        let xmlTitle = "<title>\(title)</title>"
        let xmlMeans = "<mean>\(self.markAccent(meansText: means))</mean>"
        let resultText = xmlTitle + "\r\r" + xmlMeans + "\r\r" + explains

        let attributedString = resultText.styled(with: textViewStyle)
        resultWord.attributedText = attributedString
    }

    @IBAction func resultClose(_ sender: Any) {
        resultView.isHidden = true
    }

}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

extension String {
    func indexDistance(of character: Character) -> Int? {
        guard let index = characters.index(of: character) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
