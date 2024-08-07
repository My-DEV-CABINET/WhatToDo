//
//  RealmSwift - Inquire History.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 8/5/24.
//

/// Realm
import RealmSwift

/// Apple
import Foundation

/// 조회 결과
final class InquireHistory: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var todoID: Int = 0 // Todo ID
}
