//
//  NotificationCenter.swift
//  RSSFeeder
//
//  Created by Dino Franic on 19.06.2021..
//

import Foundation
import UserNotifications
import Combine
import os

private let logger = Logger(subsystem: "RSSFeeder", category: "NotificationsManager")

struct NotificationsManager
{
    static let shared = NotificationsManager()
    
    let notificationCenter = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    let backgroundTimeApproved = PassthroughSubject<Bool, Never>()
    
    private init() {
        notificationCenter.requestAuthorization(options: options, completionHandler: { (didApprove, error) in
            if !didApprove {
                logger.warning("User has declined notifications")
                }
        })
    }
    
    func notifyOnBackgroundTimeApproved() {
        self.backgroundTimeApproved.send(true)
    }
    
    func scheduleNotification(title: String, description: String) {
        let content = UNMutableNotificationContent()

        content.title = title
        content.body = description
        content.sound = UNNotificationSound.default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "local-notification", content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                logger.error("Failed to add notification request. Error: \(error.localizedDescription)")
            }
        }
    }
}
