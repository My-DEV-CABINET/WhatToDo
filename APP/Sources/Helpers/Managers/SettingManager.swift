//
//  SettingManager.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 7/12/24.
//

import Foundation

enum UserDefaultsKey: String {
    case done
    case order
    case filter
    case backgroundColor
    case textColor
}

final class SettingManager {
    static let shared = SettingManager()

    /// UserDefaults
    let defaults = UserDefaults.standard

    /// 보기옵션
    var done: String {
        if let value = defaults.string(forKey: UserDefaultsKey.done.rawValue) {
            return value
        } else {
            return Done.all.rawValue
        }
    }

    /// 정렬
    var order: String {
        if let value = defaults.string(forKey: UserDefaultsKey.order.rawValue) {
            return value
        } else {
            return Order.desc.rawValue
        }
    }

    static func saveDoneAndOrder(done: String, order: String) {
        SettingManager.shared.defaults.set(done, forKey: UserDefaultsKey.done.rawValue)
        SettingManager.shared.defaults.set(order, forKey: UserDefaultsKey.order.rawValue)
    }

    private init() {}
}
