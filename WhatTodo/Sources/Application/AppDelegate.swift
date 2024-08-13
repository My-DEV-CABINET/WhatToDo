//
//  AppDelegate.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/16/24.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let userNotificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        userNotificationCenter.delegate = self

        let authorizationOption: UNAuthorizationOptions = [.alert, .badge, .sound]
        userNotificationCenter.requestAuthorization(options: authorizationOption) { allow, error in
            if let error = error {
                print("#### error: \(error.localizedDescription)")
            }
            print("#### \(allow)")
        }
        application.registerForRemoteNotifications()

        return true
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner])
        } else {
            completionHandler([.badge, .sound])
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
