//
//  UpdateTodoViewModel.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 6/15/24.
//

/// Rx
import RxCocoa
import RxRelay
import RxSwift

/// Apple
import Foundation

final class UpdateTodoViewModel {
    var disposeBag = DisposeBag()

    var userAction: UserActionCollection = .edit
    var todo: ToDoData?
    var isUpdate: Bool = false
}
