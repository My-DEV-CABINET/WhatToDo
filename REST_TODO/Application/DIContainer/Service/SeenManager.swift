//
//  SeenManager.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 6/8/24.
//

import Foundation

final class SeenManager {
    static let shared = SeenManager()
    
    private var seenList: Set<Int> = .init()
    var id: Int = 0
    
    func insertSeenList(id: Int) {
        seenList.insert(id)
    }
    
    /// ID 가 List 에 있는지 확인
    var existCheckInList: Bool {
        return seenList.contains(id) ? false : true
    }
    
    private init() {}
}
