//
//  DetailToDoViewModel.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/21/24.
//

import Combine
import Foundation

final class DetailToDoViewModel: ViewModelType {
    let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    private let output: PassthroughSubject<Output, Never> = .init()
    private var subcriptions = Set<AnyCancellable>()

    enum Input {
        case requestGETToDo
        case requestPOSTToDoAPI(title: String, isDone: Bool)
        case requestPUTToDoAPI(title: String, isDone: Bool)
    }

    enum Output {
        case getToDo(todo: ToDoData)
        case dismissView
        case sendError(error: Error)
    }

    var id: Int?
    var currentUserAction: UserAction = .add
}

// MARK: - API 및 Output

extension DetailToDoViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .requestGETToDo:
                self?.requestGETToDo()

            case .requestPOSTToDoAPI(let title, let isDone):
                self?.requestPOSTToDoAPI(title: title, isDone: isDone)

            case .requestPUTToDoAPI(let title, let isDone):
                self?.requestPUTToDoAPI(title: title, isDone: isDone)
            }
        }
        .store(in: &subcriptions)

        return output.eraseToAnyPublisher()
    }

    private func requestGETToDo() {
        guard let id = id else { return }
        let dto = ToDoIDDTO(id: id.description)
        let api = GETTodoAPI(dto: dto)

        apiService.request(api)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("#### Error fetching todo: \(error)")
                    self.output.send(.sendError(error: error))
                case .finished:
                    print("#### Finished \(completion)")
                }
            } receiveValue: { [weak self] response in
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: \(response)")
                guard let data = response.data else { return }
                self?.output.send(.getToDo(todo: data))
            }
            .store(in: &subcriptions)
    }

    private func requestPOSTToDoAPI(title: String, isDone: Bool) {
        let dto = ToDoBodyDTO(title: title, is_Done: isDone)
        let api = POSTToDoAPI(dto: dto)

        apiService.request(api)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("#### Error Posting todo: \(error)")
                    self.output.send(.sendError(error: error))
                case .finished:
                    print("#### Finished \(completion)")
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                output.send(.dismissView)
            }
            .store(in: &subcriptions)
    }

    /// ToDo 데이터 업데이트
    /// - Parameter todo: 변경할 ToDo 데이터
    private func requestPUTToDoAPI(title: String, isDone: Bool) {
        guard let id = id else { return }

        let idDTO = ToDoIDDTO(id: id.description)
        let bodyDTO = ToDoBodyDTO(title: title, is_Done: isDone)
        let api = PUTToDoAPI(idDTO: idDTO, bodyDTO: bodyDTO)

        apiService.requestWithEncoded(api)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("#### Error updating todo: \(error)")
                    self.output.send(.sendError(error: error))
                case .finished:
                    print("#### Finished \(completion)")
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                output.send(.dismissView)
            }
            .store(in: &subcriptions)
    }
}
