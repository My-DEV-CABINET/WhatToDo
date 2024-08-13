//
//  Extension+Date.swift
//  WhatTodo
//
//  Created by 준우의 MacBook 16 on 8/13/24.
//

import Foundation

extension Date {
    // 시간 변환
    /// 현재 날짜로부터 몇 시간 전 ~ 몇 일전 String 반환
    func conversionFromDayToPeriod() -> String {
        let currentDate = Date.now

        let period = currentDate.timeIntervalSince(self)
        // TimeInterval을 일(day) 단위로 변환
        let days = period / 86400 // 86400초 = 1일

        // 일(day) 단위로 차이 확인
        if days >= 30 {
            let months = Int(days) / 30
            print("#### \(Int(months))달 전")
            return "\(Int(months))달 전"
        } else if days >= 7 {
            let weekDays = Int(days) / 7
            print("#### \(Int(weekDays))주 전")
            return "\(Int(weekDays))주 전"
        } else if days >= 1 {
            print("#### \(Int(days))일 전")
            return "\(Int(days))일 전"
        } else {
            let hours = period / 3600 // 3600초 = 1시간
            print("#### \(Int(hours) + 9)시간 전")

            if Int(hours) == 0 {
                return "방금"
            } else {
                return "\(Int(hours))시간 전"
            }
        }
    }
}
