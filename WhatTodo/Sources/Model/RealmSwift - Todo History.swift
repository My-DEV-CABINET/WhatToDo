//
//  RealmSwift - Todo History.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 8/5/24.
//

/// Realm
import RealmSwift

/// Apple
import Foundation

/// Todo 처리 내역 결과
final class TodoHistory: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = "" // Ex) Todo ID 번째 데이터를 삭제하였습니다.
    @Persisted var created: Date = .init() // 생성일
    @Persisted var isRead: Bool = false
}
