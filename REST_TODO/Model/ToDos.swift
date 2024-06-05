//
//  ToDo.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//
import RxDataSources

import Foundation

/// ToDo 데이터들
struct ToDos: Codable {
    var data: [ToDoData]?
    var meta: ToDoMeta?
    var message: String?
}

/// 단일 ToDo 데이터
struct ToDo: Codable {
    var data: ToDoData?
    var meta: ToDoMeta?
    var message: String?
}

struct ToDoData: Codable {
    var id: Int?
    var title: String?
    var isDone: Bool?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ToDoMeta: Codable {
    var currentPage: Int?
    var from: Int?
    var lastPage: Int?
    var perPage: Int?
    var to: Int?
    var total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to
        case total
    }
}
