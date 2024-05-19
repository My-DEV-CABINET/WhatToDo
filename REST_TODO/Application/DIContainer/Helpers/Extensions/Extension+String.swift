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
            // 출력 날짜 형식 정의
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy.MM.dd"

            // 변환된 Date 객체를 String 객체로 변환
            let resultString = outputFormatter.string(from: dateDate)

            return resultString
        }

        return "n/a"
    }
}
