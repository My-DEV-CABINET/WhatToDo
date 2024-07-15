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
}

/// ViewController Identifier 모음
enum ViewControllerCollection {
    case filterVC
    case addVC
    case editVC

    var id: String {
        switch self {
        case .filterVC:
            return "FilterViewController"
        case .addVC:
            return "AddViewController"
        case .editVC:
            return "EditViewController"
        }
    }
}

/// StoryBoard Identifier 모음
enum StoryBoardCollection {
    case filterSB
    case addSB
    case editSB

    var id: String {
        switch self {
        case .filterSB:
            return "Filter"
        case .addSB:
            return "Add"
        case .editSB:
            return "Edit"
        }
    }
}
