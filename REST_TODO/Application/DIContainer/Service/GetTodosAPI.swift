//
//  GetTodosAPI.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/20/24.
//

import Foundation

struct GETTodosAPI: NetworkAPIDefinition {
    let page: String
    let filter: String
    let orderBy: String
    let perPage: String

    struct Parameter: Encodable {
        // Parameters for the GET request
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: "phplaravel-574671-2962113.cloudwaysapps.com",
            path: "/api/v2/todos",
            query: [
                "page": page,
                "filter": filter,
                "order_by": orderBy,
                "per_page": perPage,
            ]
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .get,
            headers: ["Content-Type": "application/json"]
        )
    }
}

struct GETTodoAPI: NetworkAPIDefinition {
    let id: String

    struct Parameter: Encodable {
        let id: String
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: "phplaravel-574671-2962113.cloudwaysapps.com",
            path: "/api/v2/todos"
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .get,
            headers: ["Content-Type": "application/json"],
            parameters: Parameter(id: id)
        )
    }
}

struct GETSearchToDosAPI: NetworkAPIDefinition {
    let query: String
    let page: String
    let filter: String
    let orderBy: String
    let perPage: String

    struct Parameter: Encodable {
        let query: String
        let page: String
        let filter: String
        let orderBy: String
        let perPage: String
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: "phplaravel-574671-2962113.cloudwaysapps.com",
            path: "/api/v2/todos/search"
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .get,
            headers: ["Content-Type": "application/json"],
            parameters: Parameter(
                query: query,
                page: page,
                filter: filter,
                orderBy: orderBy,
                perPage: perPage
            )
        )
    }
}

struct POSTToDoAPI: NetworkAPIDefinition {
    let title: String
    let isDone: String

    struct Parameter: Encodable {
        let title: String
        let is_Done: String
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: "phplaravel-574671-2962113.cloudwaysapps.com",
            path: "/api/v2/todos"
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .post,
            headers: ["Content-Type": "application/json"],
            parameters: Parameter(
                title: title,
                is_Done: isDone
            )
        )
    }
}

struct PUTToDoAPI: NetworkAPIDefinition {
    let id: String
    let title: String
    let isDone: String

    struct Parameter: Encodable {
        let title: String
        let is_Done: String
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: "phplaravel-574671-2962113.cloudwaysapps.com/\(id)",
            path: "/api/v2/todos"
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .put,
            headers: ["Content-Type": "application/json"],
            parameters: Parameter(
                title: title,
                is_Done: isDone
            )
        )
    }
}

struct DELETEToDoAPI: NetworkAPIDefinition {
    let id: String

    struct Parameter: Encodable {
        let id: String
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: "phplaravel-574671-2962113.cloudwaysapps.com/",
            path: "/api/v2/todos"
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .delete,
            headers: ["Content-Type": "application/json"],
            parameters: Parameter(id: id)
        )
    }
}
