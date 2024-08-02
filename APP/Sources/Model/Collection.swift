//
//  Collection.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 7/15/24.
//

import Foundation

/// Custom DispatchQueue 모음
enum QueueCollection: String {
    case add
    case selected
    case refresh
    case search
    case searchCancel
    case paging
    case save
}

/// ViewController Identifier 모음
enum ViewControllerCollection {
    case filter
    case create
    case update

    var id: String {
        switch self {
        case .filter:
            return "FilterToDoVC"
        case .create:
            return "CreateToDoVC"
        case .update:
            return "UpdateToDoVC"
        }
    }
}

/// StoryBoard Identifier 모음
enum StoryBoardCollection {
    case filter
    case create
    case update

    var id: String {
        switch self {
        case .filter:
            return "FilterTodo"
        case .create:
            return "CreateTodo"
        case .update:
            return "UpdateTodo"
        }
    }
}
