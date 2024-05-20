//
//  ToDoViewModel.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

import Combine
import Foundation

final class ToDoViewModel: ViewModelType {
    let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    private let output: PassthroughSubject<Output, Never> = .init()
    private var subcriptions = Set<AnyCancellable>()

    private(set) var todos: [ToDoData]?
    private(set) var isTapped: Bool = false
    private(set) var fetchingMore: Bool = false

    enum Input {
        case requestGETTodos
        case requestGETSearchToDosAPI(query: String)

        case requestScrolling
        case requestTapFloattingButton
    }

    enum Output {
        case showGETTodos(todos: [ToDoData])
        case showGETSearchToDosAPI(todos: [ToDoData])

        case scrolling(todos: [ToDoData])
        case tapFloattingButton(isTapped: Bool)
    }

    var groupedTodos: [String: [ToDoData]] {
        let groupedDictionary = Dictionary(grouping: todos ?? []) { todo in
            return todo.updatedAt?.dateFormatterForDate() ?? ""
        }
        print("&&&& \(groupedDictionary.keys)")
        return groupedDictionary
    }

    var sortedSectionKeys: [String] {
        return groupedTodos.keys.sorted(by: >)
    }

    var page: Int = 1
}

// MARK: - API 및 Output

extension ToDoViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .requestGETTodos:
                self?.requestGETTodos()
            case .requestGETSearchToDosAPI(let query):
                self?.requestGETSearchToDosAPI(query: query)

            case .requestScrolling:
                self?.requestScrolling()
            case .requestTapFloattingButton:
                self?.toggleIsTapped()
            }
        }
        .store(in: &subcriptions)

        return output.eraseToAnyPublisher()
    }

    private func requestGETTodos() {
        let api = GETTodosAPI(page: page.description, filter: Filter.updatedAt.rawValue, orderBy: Order.desc.rawValue, perPage: 10.description)

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

    private func requestGETSearchToDosAPI(query: String) {
        resetPageCount()
        let dto = ToDoQueryDTO(query: query, page: page.description, filter: Filter.updatedAt.rawValue, orderBy: Order.desc.rawValue, perPage: 10.description)
        let api = GETSearchToDosAPI(dto: dto)

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

    private func requestScrolling() {
        let api = GETTodosAPI(page: page.description, filter: Filter.updatedAt.rawValue, orderBy: Order.desc.rawValue, perPage: 10.description)

        apiService.request(api)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching todos: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                todos! += response.data ?? []
                output.send(.scrolling(todos: response.data ?? []))
            }
            .store(in: &subcriptions)
    }
}

// MARK: - ViewModel's Origin Method

extension ToDoViewModel {
    func toggleIsTapped() {
        isTapped.toggle()
        output.send(.tapFloattingButton(isTapped: isTapped))
    }

    func increasePageCount() {
        page += 1
    }

    func resetPageCount() {
        page = 1
    }

    func toggleFetchingMore() {
        fetchingMore.toggle()
    }
}
