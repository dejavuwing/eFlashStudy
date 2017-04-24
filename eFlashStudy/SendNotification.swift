//
//  SendNotification.swift
//  eFlashStudy
//
//  Created by nGle on 2017. 4. 3..
//  Copyright © 2017년 Tongchun. All rights reserved.
//
//  https://useyourloaf.com/blog/local-notifications-with-ios-10/
//

import Foundation
import UserNotifications
import SwiftyJSON

enum ActionIdentifier: String {
    case openApp
    case elsePattern
}

@available(iOS 10.0, *)
class SendNotification: NSObject {

    /// 푸시에 등록한다.
    static func scheduleNotification(title: String, subtitle: String, body: String) {
        let center = UNUserNotificationCenter.current()

        // 등록되어 있는 푸시를 모두 삭제한다.
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()

        let openApp     = UNNotificationAction(identifier: ActionIdentifier.openApp.rawValue, title: "Open", options: [.foreground])
        let elsePattern = UNNotificationAction(identifier: ActionIdentifier.elsePattern.rawValue, title: "Pattern", options: [])
        let category    = UNNotificationCategory(identifier: "Actions", actions: [openApp, elsePattern], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])

        // body가 없을경우 Notification이 노출되지 않는다.
        var emptyBodyString = "..."
        if body != "" {
            emptyBodyString = body
        }

        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = emptyBodyString
        content.sound = .default()
        content.badge = 1
        content.categoryIdentifier = "Actions"

        // 앱실행 후 1분후 Notification 발송
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: "eFlashStudy", content: content, trigger: trigger)
        center.delegate = self as? UNUserNotificationCenterDelegate
        center.add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }

    /// 등록된 모든 푸시를 삭제한다.
    static func deleteNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }

    /// 푸시를 보내기 위해 Pattern 데이터를 가져온다.
    static func addScheduledNotification() {

        // StudyDataStruct에 데이터가 쌓여 있다면 Puth를 준비한다.
        if StudyDataStruct.patterns.count > 1 {
            let index = RandomIndex.getIndex(maxNum: UInt32(StudyDataStruct.patterns.count))
            let pattern = StudyDataStruct.patterns[index].title
            let means = StudyDataStruct.patterns[index].means.replacingOccurrences(of: "\\n", with: "\r")
            let explains = StudyDataStruct.patterns[index].explains.replacingOccurrences(of: "\\n", with: "\r")

            scheduleNotification(title: pattern, subtitle: means, body: explains)
        }
    }
}

@available(iOS 10.0, *)
class SendNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
// If you want to respond to actionable notifications or receive notifications while your app is in the foreground you need to implement the UNUserNotificationCenterDelegate.

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        // Delivers a notification to an app running in the foreground.
        completionHandler([.alert, .sound, .badge])
    }


    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        print("GOT A NOTIFICATION")

        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case ActionIdentifier.openApp.rawValue:
            print("OpenApp")
        case ActionIdentifier.elsePattern.rawValue:
            print("elsePattern")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}
