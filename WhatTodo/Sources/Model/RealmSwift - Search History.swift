//
//  RealmSwift - Search History.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 8/5/24.
//

/// Realm
import RealmSwift

/// Apple
import Foundation

/// 검색 결과
final class SearchHistory: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = "" // 검색어
    @Persisted var created: Date = .init() // 검색어 생성일
}
