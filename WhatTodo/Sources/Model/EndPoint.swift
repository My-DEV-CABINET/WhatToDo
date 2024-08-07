//
//  API.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 6/27/24.
//

import Foundation

enum Filter: String {
    case createdAt = "created_at"
    case updatedAt = "updated_at"
}

enum Order: String {
    case desc
    case asc
}

enum Done: String {
    case all
    case onlyCompleted
    case onlyNonCompleted
}
