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

    private(set) var todos: [ToDoData]?

    var groupedTodos: [String: [ToDoData]] {
        let groupedDictionary = Dictionary(grouping: todos ?? []) { todo in
            return todo.createdAt?.dateFormatterForDate() ?? ""
        }
        return groupedDictionary
    }

    var sortedSectionKeys: [String] {
        return groupedTodos.keys.sorted(by: >)
    }

    enum Input {
        case requestGETTodos
    }

    enum Output {
        case showGETTodos(todos: [ToDoData])
    }

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .requestGETTodos:
                self?.requestGETTodos()
            }
        }
        .store(in: &subcriptions)

        return output.eraseToAnyPublisher()
    }

    private func requestGETTodos() {
        let api = GETTodosAPI(page: 1.description, filter: Filter.updatedAt.rawValue, orderBy: Order.desc.rawValue, perPage: 10.description)

        apiService.request(api)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching todos: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] response in
                self?.todos = response.data
                self?.output.send(.showGETTodos(todos: response.data ?? []))
            }
            .store(in: &subcriptions)
    }
}

// apiService.requestTodosFromServer(dto: dto)
//            .sink { [weak self] completion in
//                print("&&&& Completion : \(completion)")
//            } receiveValue: { [weak self] todo in
//                print("#### \(todo)")
//                self?.todos = todo.data
//                self?.output.send(.showTodos(todos: todo.data ?? []))
//            }
//            .store(in: &subcriptions)
