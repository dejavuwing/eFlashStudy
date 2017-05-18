//
//  SettingTableController.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 5. 12..
//  Copyright © 2017년 Tongchun. All rights reserved.
//

import UIKit

enum SettingKey {
    case recentCategory
    case pushPattern
    case flashSecond
}

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var flashSlider: UISlider!
    @IBOutlet weak var flashSecond: UILabel!

    var toDay: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Options"

        // 패턴 푸시 설정값을 가져온다.
        if RealManager.existAppSetting(key: .pushPattern) {
            if RealManager.getAppSetting(key: .pushPattern) == "YES" {
                pushSwitch.setOn(true, animated: true)
            } else {
                pushSwitch.setOn(false, animated: true)
            }
        } else {
            RealManager.setAppSetting(key: .pushPattern, value: "YES")
        }

        // Flash Second 설정값을 가져온다.
        if RealManager.existAppSetting(key: .flashSecond) {
            let strCurrentSecond = RealManager.getAppSetting(key: .flashSecond)
            let fltCurrentSecond = (strCurrentSecond as NSString).floatValue

            flashSlider.setValue(fltCurrentSecond, animated: true)
            flashSecond.text = "(\(strCurrentSecond)초)"

        } else {
            // flashSecond 값이 없다면 모든 Option 값을 초기화 한다.
            RealManager.setDefaultOption()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // 읽은 기록 삭제하기
    @IBAction func resetCount(_ sender: Any) {
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

    // 페턴 알림 설정 (Switch)
    @IBAction func switchPushPattern(_ sender: Any) {
        if pushSwitch.isOn {
            RealManager.setAppSetting(key: .pushPattern, value: "YES")

        } else {
            RealManager.setAppSetting(key: .pushPattern, value: "NO")
        }
    }

    @IBAction func slideFlashSecond(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        flashSecond.text = "(\(currentValue)초)"
        RealManager.setAppSetting(key: .flashSecond, value: "\(currentValue)")
    }
}
