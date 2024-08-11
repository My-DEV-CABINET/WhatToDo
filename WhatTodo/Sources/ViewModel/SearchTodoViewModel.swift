//
//  SearchTodoViewModel.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 8/3/24.
//

// Rx
import RxCocoa
import RxRelay
import RxSwift

// Apple
import Foundation

final class SearchTodoViewModel {
    var dbManager = DBManager(read: .searchHistory)

    var searchBehaviorSubject: BehaviorSubject<[SearchHistory]> = .init(value: [])
    var disposeBag = DisposeBag()

    func fetchSearchHistory() {
        let searchs = dbManager.searchHistories
        searchBehaviorSubject.onNext(searchs)
    }

    func createSearchHistory(searchText: String) {
        dbManager.createSearchHistory(name: searchText, createdDate: Date.now)
        searchBehaviorSubject.onNext(dbManager.searchHistories)
    }

    func deleteSearchHistory(name: String) {
        dbManager.deleteSearchHistory(name: name)
        searchBehaviorSubject.onNext(dbManager.searchHistories)
    }

    func deleteAllSearchHistory() {
        dbManager.deleteAllSearhHistory()
        searchBehaviorSubject.onNext(dbManager.searchHistories)
    }
}
