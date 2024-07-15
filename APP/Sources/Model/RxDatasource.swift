//
//  RxDatasource.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 7/15/24.
//

/// RxSwift
import RxDataSources

/// Apple
import Foundation

// MARK: - RxDataSource Section Model

struct SectionOfCustomData {
    var header: String
    var items: [ToDoData]

    init(header: String, items: [ToDoData]) {
        self.header = header
        self.items = items
    }
}

extension SectionOfCustomData: SectionModelType {
    typealias Item = ToDoData

    init(original: SectionOfCustomData, items: [Item]) {
        self = original
        self.items = items
    }
}
