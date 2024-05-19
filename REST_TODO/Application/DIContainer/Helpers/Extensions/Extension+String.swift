//
//  Extension+String.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/19/24.
//

import Foundation

extension String {
    func dateFormatter() -> String {
        // 입력 날짜 형식 정의
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        // 출력 날짜 형식 정의
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"

        // 입력 문자열을 Date 객체로 변환
        if let date = inputFormatter.date(from: self) {
            // Date 객체를 원하는 형식의 문자열로 변환
            return outputFormatter.string(from: date)
        } else {
            return ""
        }
    }
}
