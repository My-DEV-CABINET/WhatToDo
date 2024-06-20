//
//  Extension+UserNotifications.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 6/20/24.
//

import Foundation
import UserNotifications
 
extension UNUserNotificationCenter {
    func addNotificationRequest(title: String, details: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = details
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                
        self.add(request, withCompletionHandler: nil)
    }
}
