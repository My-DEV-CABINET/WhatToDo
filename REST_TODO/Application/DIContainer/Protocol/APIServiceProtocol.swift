//
//  NetworkServiceProtocol.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

import Combine
import Foundation

protocol APIServiceProtocol {
    func requestTodosFromServer(dto: ToDoResponseDTO) -> AnyPublisher<ToDo, Error>
    func requestQueryToDosFromServer() -> AnyPublisher<ToDo, Error>

    func insertToDoToServer() -> AnyPublisher<Bool, Error>
    func updateToDoAtServer() -> AnyPublisher<Bool, Error>
    func removeToDoAtServer() -> AnyPublisher<Bool, Error>
}
