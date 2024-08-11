//
//  HistoryTodoViewModel.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 8/5/24.
//

// Rx
import RxCocoa
import RxRelay
import RxSwift

// Apple
import Foundation

final class HistoryTodoViewModel {
    var dbManager = DBManager(read: .todoHistory)

    var historyBehaviorSubject: BehaviorSubject<[TodoHistory]> = .init(value: [])
    var editRealy = BehaviorRelay(value: false)

    var disposeBag = DisposeBag()
    
    func fetchTodoHistory() {
        let todoHistories = dbManager.todoHistories
        historyBehaviorSubject.onNext(todoHistories)
    }
    
    func deleteTodoHistory(name: String) {
        dbManager.deleteTodoHistory(name: name)
        historyBehaviorSubject.onNext(dbManager.todoHistories)
    }
    
    func updateAllTodoHistory() {
        dbManager.updateAllTodoHistory()
        historyBehaviorSubject.onNext(dbManager.todoHistories)
    }
}
