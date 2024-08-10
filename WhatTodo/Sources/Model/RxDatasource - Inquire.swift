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

struct SectionOfInquireData {
    var header: String
    var items: [InquireHistory]

    init(header: String, items: [InquireHistory]) {
        self.header = header
        self.items = items
    }
}

extension SectionOfInquireData: SectionModelType {
    typealias Item = InquireHistory

    init(original: SectionOfInquireData, items: [Item]) {
        self = original
        self.items = items
    }
}
