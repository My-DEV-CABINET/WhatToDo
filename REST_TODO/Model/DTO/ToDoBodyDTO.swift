//
//  x.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/19/24.
//

import Foundation

struct ToDoBodyDTO: Codable {
    let title: String
    let is_Done: Bool
}

struct ToDoIDDTO: Codable {
    let id: String
}

struct ToDoQueryDTO: Codable {
    let query: String
    let page: String
    let filter: String
    let orderBy: String
    let perPage: String
}
