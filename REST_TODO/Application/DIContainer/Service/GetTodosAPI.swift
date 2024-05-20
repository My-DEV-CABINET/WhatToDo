//
//  GetTodosAPI.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/20/24.
//

import Foundation

// 모든 할일 목록 가져오기
struct GETTodosAPI: NetworkAPIDefinition {
    let page: String
    let filter: String
    let orderBy: String
    let perPage: String

    // BODY Parameter
    struct Parameter: Encodable {
        // Parameters for the GET request
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: Constants.host,
            path: Constants.path,
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
            headers: [Constants.headerFieldKey: Constants.headerFieldValue]
        )
    }
}

// 특정 할일 가져오기 - ID 기반
struct GETTodoAPI: NetworkAPIDefinition {
    let dto: ToDoIDDTO

    struct Parameter: Encodable {
        // Parameters for the GET request
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: Constants.host,
            path: Constants.path,
            query: [
                "id": dto.id,
            ]
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .get,
            headers: [Constants.headerFieldKey: Constants.headerFieldValue]
        )
    }
}

// 검색 데이터 가져오기
struct GETSearchToDosAPI: NetworkAPIDefinition {
    let dto: ToDoQueryDTO

    struct Parameter: Encodable {
        // Parameters for the GET request
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: Constants.host,
            path: Constants.searchPath,
            query: [
                "query": dto.query,
                "filter": dto.filter,
                "order_by": dto.orderBy,
                "page": dto.page,
                "per_page": dto.perPage,
            ]
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .get,
            headers: [Constants.headerFieldKey: Constants.headerFieldValue]
        )
    }
}

// 할일 추가
struct POSTToDoAPI: NetworkAPIDefinition {
    let dto: ToDoBodyDTO

    struct Parameter: Encodable {
        let title: String
        let is_done: Bool
    }

    struct Response: Decodable {
        // Response for the POST request
    }

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: Constants.host,
            path: Constants.postPath
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .post,
            headers: [
                Constants.accept: Constants.headerFieldValue,
                Constants.headerFieldKey: Constants.headerFieldValue,
            ],
            parameters: Parameter(
                title: dto.title,
                is_done: dto.is_Done
            )
        )
    }
}

// 특정 할일 수정 - ID 기반
struct PUTToDoAPI: NetworkAPIDefinition {
    let idDTO: ToDoIDDTO
    let bodyDTO: ToDoBodyDTO

    struct Parameter: Encodable {
        let title: String
        let is_Done: String
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: Constants.host,
            path: Constants.path,
            query: ["id": idDTO.id]
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .put,
            headers: [Constants.headerFieldKey: Constants.headerFieldValue],
            parameters: Parameter(
                title: bodyDTO.title,
                is_Done: bodyDTO.is_Done.description
            )
        )
    }
}

// 기존 할일 삭제하기 - ID 기반
struct DELETEToDoAPI: NetworkAPIDefinition {
    let dto: ToDoIDDTO

    struct Parameter: Encodable {
        // Parameters for the DELETE request
    }

    typealias Response = ToDo

    var urlInfo: NetworkAPI.URLInfo {
        NetworkAPI.URLInfo(
            host: Constants.host,
            path: Constants.path,
            query: ["id": dto.id]
        )
    }

    var requestInfo: NetworkAPI.RequestInfo<Parameter> {
        NetworkAPI.RequestInfo(
            method: .delete,
            headers: [Constants.headerFieldKey: Constants.headerFieldValue]
        )
    }
}
