//
//  ToDoGETDTO.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/19/24.
//

import Foundation

struct ToDoGETDTO {
    let query: String? = nil
    let page: Int?
    let filter: Filter?
    let orderBy: Order?
    let isDone: Bool? = nil
    let perPage: Int?
}
