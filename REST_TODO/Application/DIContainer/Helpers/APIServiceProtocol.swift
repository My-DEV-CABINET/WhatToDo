//
//  NetworkServiceProtocol.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

import Foundation

protocol APIServiceProtocol {
    func requestTodosFromServer()
    func insertToDoToServer()
    func updateToDoAtServer()
    func removeToDoAtServer()
    func requestQueryToDosFromServer()
}
