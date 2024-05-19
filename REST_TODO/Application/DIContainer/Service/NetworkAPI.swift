//
//  EndPoint.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/19/24.
//

import Foundation

enum ContentType {
    case json

    var code: String {
        switch self {
        case .json:
            return "application/json"
        }
    }
}

enum Filter: String {
    case createdAt = "created_at"
    case updatedAt = "updated_at"
}

enum Order: String {
    case desc
    case asc
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkAPI {
    case requestTodos(dto: ToDoResponseDTO) // GET - 전체 데이터 조회
    case requestTodoWithID(id: Int)
    case requestSearchTodos(dto: ToDoResponseDTO) // GET - ID 사용하여 데이터 조회
    case postTodo(dto: ToDoPOSTDTO) // POST - 데이터 추가
    case putTodo(id: Int, dto: ToDoPOSTDTO) // PUT - 데이터 수정
    case deleteTodo(id: Int) // DELETE - 데이터 삭제

    var baseURL: String {
        return Constants.BASE_URL
    }

    var method: HTTPMethod {
        switch self {
        case .requestTodos, .requestTodoWithID, .requestSearchTodos:
            return .get
        case .postTodo:
            return .post
        case .putTodo:
            return .put
        case .deleteTodo:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .requestTodos:
            return "/api/v2/todos"
        case .requestTodoWithID(let id):
            return "/api/v2/todos/\(id)"
        case .requestSearchTodos:
            return "/api/v2/todos/search"
        case .postTodo, .putTodo, .deleteTodo:
            return "/api/v2/todos"
        }
    }

    var param: [URLQueryItem] {
        switch self {
        case .requestTodos(let dto):
            return [
                URLQueryItem(name: "filter", value: dto.filter?.rawValue),
                URLQueryItem(name: "order_by", value: dto.orderBy?.rawValue),
                URLQueryItem(name: "page", value: dto.page?.description),
                URLQueryItem(name: "per_page", value: dto.perPage?.description)
            ]
        case .requestTodoWithID(id: let id), .deleteTodo(let id):
            return [
                URLQueryItem(name: "id", value: id.description)
            ]
        case .postTodo(let dto):
            return [
                URLQueryItem(name: "title", value: dto.title),
                URLQueryItem(name: "is_done", value: dto.isDone.description)
            ]

        case .putTodo(let id, let dto):
            return [
                URLQueryItem(name: "id", value: id.description),
                URLQueryItem(name: "title", value: dto.title),
                URLQueryItem(name: "is_done", value: dto.isDone.description)
            ]
        case .requestSearchTodos(let dto):
            return [
                URLQueryItem(name: "query", value: dto.query),
                URLQueryItem(name: "filter", value: dto.filter?.rawValue),
                URLQueryItem(name: "order_by", value: dto.orderBy?.rawValue),
                URLQueryItem(name: "page", value: dto.page?.description),
                URLQueryItem(name: "per_page", value: dto.perPage?.description),
                URLQueryItem(name: "is_done", value: dto.isDone?.description)
            ]
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL
        var components = URLComponents(string: url)
        components?.path = path
        components?.queryItems = param

        guard let url = components?.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(ContentType.json.code, forHTTPHeaderField: Constants.HTTP_Header_Field)

        return request
    }
}
