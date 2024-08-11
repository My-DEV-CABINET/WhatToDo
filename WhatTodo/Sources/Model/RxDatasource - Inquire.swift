//
//  RxDatasource - Inquire.swift
//  WhatTodo
//
//  Created by 준우의 MacBook 16 on 8/10/24.
//

/// RxSwift
import RxDataSources

/// Apple
import Foundation

// MARK: - RxDataSource Section Model

struct SectionOfHistoryData {
    var header: String
    var items: [TodoHistory]

    init(header: String, items: [TodoHistory]) {
        self.header = header
        self.items = items
    }
}

extension SectionOfHistoryData: SectionModelType {
    typealias Item = TodoHistory

    init(original: SectionOfHistoryData, items: [Item]) {
        self = original
        self.items = items
    }
}
