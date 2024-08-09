//
//  Extension+String.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/19/24.
//

import Foundation

extension String {
    func dateFormatterForTime() -> String {
        let dateString = self

        // 입력 날짜 형식 정의
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

        // 입력 문자열을 Date 객체로 변환
        if let dateDate = inputFormatter.date(from: dateString) {
            // 출력 날짜 형식 정의
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "h:mm a"

            // 변환된 Date 객체를 String 객체로 변환
            let resultString = outputFormatter.string(from: dateDate)

            return resultString
        }

        return "n/a"
    }

    func dateFormatterForDate() -> String {
        let dateString = self

        // 입력 날짜 형식 정의
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"

        // 입력 문자열을 Date 객체로 변환
        if let dateDate = inputFormatter.date(from: dateString) {
            // 9시간을 뺀 새로운 날짜 계산
            if let adjustedDate = Calendar.current.date(byAdding: .hour, value: -9, to: dateDate) {
                // 출력 날짜 형식 정의
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = "yyyy.MM.dd"

                // 변환된 Date 객체를 String 객체로 변환
                let resultString = outputFormatter.string(from: adjustedDate)

                return resultString
            }
        }

        return "n/a"
    }

    func convertFilterOption() -> Done {
        switch self {
        case "모두보기":
            return .all
        case "완료":
            return .onlyCompleted
        case "미완료":
            return .onlyNonCompleted
        default:
            return .all
        }
    }

    func convertOrderOption() -> Order {
        switch self {
        case "내림차순":
            return .desc
        case "오름차순":
            return .asc
        default:
            return .desc
        }
    }

    func convertDoneTag() -> Int {
        switch self {
        case Done.all.rawValue:
            return 0
        case Done.onlyCompleted.rawValue:
            return 1
        case Done.onlyNonCompleted.rawValue:
            return 2
        default:
            return 0
        }
    }

    func convertOrderTag() -> Int {
        switch self {
        case Order.desc.rawValue:
            return 0
        case Order.asc.rawValue:
            return 1
        default:
            return 0
        }
    }
}
