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

        print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: \(url)")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw NetworkError.serverError(code: 0, error: "Server error")
                }
                guard (200 ... 299).contains(response.statusCode) else {
                    throw NetworkError.serverError(code: response.statusCode, error: "Server error with code: \(response.statusCode)")
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

    func requestWithEncoded<T: NetworkAPIDefinition>(_ api: T) -> AnyPublisher<T.Response, Error> where T == PUTToDoAPI {
        let url = api.urlInfo.url
        var request = api.requestInfo.requests(url: url)

        let requestParams: [String: String] = ["title": api.bodyDTO.title, "is_done": api.bodyDTO.is_Done.description]
        request.percentEncodeParameters(parameters: requestParams)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw NetworkError.serverError(code: 0, error: "Server error")
                }

                if !(200 ... 299).contains(response.statusCode) {
                    let responseBody = String(data: output.data, encoding: .utf8) ?? "No response body"
                    debugPrint("#### RESPONSE BODY: \(responseBody)")
                    throw NetworkError.serverError(code: response.statusCode, error: "Server error with code: \(response.statusCode), response body: \(responseBody)")
                }
                return output.data
            }
            .decode(type: T.Response.self, decoder: JSONDecoder())
            .mapError { error in
                debugPrint("#### DECODE ERROR: \(error)")
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
