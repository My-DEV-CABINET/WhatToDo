//
//  APIService.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/19/24.
//

import Combine
import Foundation

enum NetworkError: Error, Equatable {
    case badURL(_ error: String)
    case apiError(code: Int, error: String)
    case invalidJSON(_ error: String)
    case unauthorized(code: Int, error: String)
    case badRequest(code: Int, error: String)
    case serverError(code: Int, error: String)
    case noResponse(_ error: String)
    case unableToParseData(_ error: String)
    case unknown(code: Int, error: String)
}

final class APIService: APIServiceProtocol {
    func request<T: NetworkAPIDefinition>(_ api: T) -> AnyPublisher<T.Response, Error> {
        let url = api.urlInfo.url
        let request = api.requestInfo.requests(url: url)

        print("#### url: \(url) :: Request : \(request)")

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard output.response is HTTPURLResponse else {
                    throw NetworkError.serverError(code: 0, error: "Server error")
                }
                return output.data
            }
            .decode(type: T.Response.self, decoder: JSONDecoder())
            .mapError { error in
                return NetworkError.invalidJSON(String(describing: error))
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

//    func requestTodosFromServer(dto: ToDoResponseDTO) -> AnyPublisher<ToDo, any Error> {
//        do {
//            let url = try NetworkAPI.requestTodos(dto: dto).asURLRequest()
//
//            return URLSession.shared
//                .dataTaskPublisher(for: url)
//                .tryMap { output in
//                    guard output.response is HTTPURLResponse else {
//                        throw NetworkError.serverError(code: 0, error: "Server error")
//                    }
//                    return output.data
//                }
//                .decode(type: ToDo.self, decoder: JSONDecoder())
//                .mapError { error in
//                    return NetworkError.invalidJSON(String(describing: error))
//                }
//                .eraseToAnyPublisher()
//        } catch {
//            return Fail(error: NetworkError.badURL("Invalid URL!")).eraseToAnyPublisher()
//        }
//    }
