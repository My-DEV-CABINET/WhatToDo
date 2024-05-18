//
//  ToDo.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

import Foundation

struct ToDo: Codable {
    let data: ToDoData?
    let meta: ToDoMeta?
    let message: String?
}

struct ToDoData: Codable {
    let id: Int?
    let title: String?
    let isDone: Bool?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ToDoMeta: Codable {
    let currentPage: Int?
    let from: Int?
    let lastPage: Int?
    let perPage: Int?
    let to: Int?
    let total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to
        case total
    }
}
