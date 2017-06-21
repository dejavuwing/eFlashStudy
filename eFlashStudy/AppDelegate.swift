//
//  AppDelegate.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 3. 3..
//  Copyright © 2017년 Tongchun. All rights reserved.
//
//  Push : https://eladnava.com/send-push-notifications-to-ios-devices-using-xcode-8-and-swift-3/
//

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Thread.sleep(forTimeInterval: 0.2)

        // Start PlistManager
        PlistManager.sharedInstance.startPlistManager()

        if #available(iOS 10.0, *) {
            let notificationDelegate = SendNotificationDelegate()
            let center = UNUserNotificationCenter.current()
            center.delegate = notificationDelegate

            center.requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, _) in
                if !accepted {
                    print("Notification access denied.")
                }
            }
        }

        // json 파일에더 데이터를 불러온다.
        LoadData.putData(categoryArray: [.word, .pattern, .dialogue, .ebs])

        // Use Firebase library to configure APIs
        FIRApp.configure()

        // Initialize Google Mobile Ads SDK
        GADMobileAds.configure(withApplicationID: "ca-app-pub-2253648664537078/3436041743")

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("앱이 Background로 갔습니다.")

        if #available(iOS 10.0, *) {
            // 앱이 Background로 갈때마다 새로운 푸시를 저장합니다.
            // StudyDataStruct.pattern에 데이터를 저장하는 시간을 고려해 Background로 갈때 한다.
            SendNotification.addScheduledNotification()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("앱이 Foreground로 나왔습니다.")

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("앱이 다시 활성화 되었습니다.")

        // badge 를 제거한다.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
}
