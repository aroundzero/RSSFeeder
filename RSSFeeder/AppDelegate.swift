//
//  AppDelegate.swift
//  RSSFeeder
//
//  Created by Dino Franic on 20.06.2021..
//

import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationsManager = NotificationsManager.shared
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // TODO Switch to BackgroundTasks framework
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
        return true
    }
        
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler:
                     @escaping (UIBackgroundFetchResult) -> Void) {
        
        notificationsManager.notifyOnBackgroundTimeApproved()
        completionHandler(.newData)
    }
}
