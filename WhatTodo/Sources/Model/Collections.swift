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
    case read
    case filter
    case create
    case detail
    case alert
    case search
    case history

    var id: String {
        switch self {
        case .read:
            return "ReadToDoVC"
        case .filter:
            return "FilterToDoVC"
        case .create:
            return "CreateToDoVC"
        case .detail:
            return "DetailToDoVC"
        case .alert:
            return "AlertVC"
        case .search:
            return "SearchToDoVC"
        case .history:
            return "HistoryToDoVC"
        }
    }
}

/// StoryBoard Identifier 모음
enum StoryBoardCollection {
    case read
    case filter
    case create
    case detail
    case alert
    case search
    case history

    var id: String {
        switch self {
        case .read:
            return "ReadTodo"
        case .filter:
            return "FilterTodo"
        case .create:
            return "CreateTodo"
        case .detail:
            return "DetailTodo"
        case .alert:
            return "AlertTodo"
        case .search:
            return "SearchTodo"
        case .history:
            return "TodoHistory"
        }
    }
}

/// Identifier 모음
enum IdentifierCollection: String {
    case todoCell = "ToDoCell"
    case headerView = "HeaderView"
    case searchCell = "SearchCell"
    case historyCell = "HistoryCell"
}

/// UserAction  모음
enum UserActionCollection {
    case add /// 데이터 추가
    case edit /// 데이터 편집
}

// MARK: - History Type 모음

/// History Type 모음
enum HistoryTypeCollection {
    case add
    case delete
}

// MARK: - DB: 내역 타입 모음

/// DB: 내역 타입 모음
enum ReadDataTypeCollection {
    case todoHistory // Todo 처리 내역
    case searchHistory // 검색결과 처리 내역
    case inquireHistory // 조회 결과 처리 내역
    case all // 전부 조회
}
