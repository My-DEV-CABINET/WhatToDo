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
        case requestPUTToDoAPI(title: String, isDone: Bool)
    }

    enum Output {
        case PUTToDoAPI
    }
}

// MARK: - API 및 Output

extension DetailToDoViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .requestPUTToDoAPI(let title, let isDone):
                self?.requestPOSTToDoAPI(title: title, isDone: isDone)
            }
        }
        .store(in: &subcriptions)

        return output.eraseToAnyPublisher()
    }

    private func requestPOSTToDoAPI(title: String, isDone: Bool) {
        let dto = ToDoBodyDTO(title: title, is_Done: isDone)
        let api = POSTToDoAPI(dto: dto)

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
                output.send(.PUTToDoAPI)
            }
            .store(in: &subcriptions)
    }
}
