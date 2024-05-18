//
//  ToDoViewModel.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

import Combine
import Foundation

// To Do: ViewModel 작업 예정
final class ToDoViewModel: ViewModelType {
    let apiService: APIServiceProtocol

    private let output: PassthroughSubject<Output, Never> = .init()
    private var subcriptions = Set<AnyCancellable>()

    var todos: ToDo?

    var todosCount: Int = 0

    enum Input {
        case requestTodos(dto: ToDoResponseDTO)
    }

    enum Output {
        case showTodos(todos: ToDo)
    }

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .requestTodos(let dto):
                self?.requestTodos(dto: dto)
            }
        }
        .store(in: &subcriptions)

        return output.eraseToAnyPublisher()
    }

    private func requestTodos(dto: ToDoResponseDTO) {
        apiService.requestTodosFromServer(dto: dto)
            .sink { [weak self] completion in
                print("&&&& Completion : \(completion)")
            } receiveValue: { [weak self] todo in
                print("#### \(todo)")
                self?.todos = todo
                self?.todosCount = todo.data?.count ?? 0
                self?.output.send(.showTodos(todos: todo))
            }
            .store(in: &subcriptions)
    }
}
