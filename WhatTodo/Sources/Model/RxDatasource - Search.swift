//
//  RxDatasource - Search.swift
//  WhatTodo
//
//  Created by 준우의 MacBook 16 on 8/10/24.
//

/// RxSwift
import RxDataSources

/// Apple
import Foundation

// MARK: - RxDataSource Section Model

struct SectionOfSearchData {
    var header: String
    var items: [SearchHistory]

    init(header: String, items: [SearchHistory]) {
        self.header = header
        self.items = items
    }
}

extension SectionOfSearchData: SectionModelType {
    typealias Item = SearchHistory

    init(original: SectionOfSearchData, items: [Item]) {
        self = original
        self.items = items
    }
}
