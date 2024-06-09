//
//  Constants.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/19/24.
//

import Foundation

struct Constants {
    /// Scheme : https://
    static let scheme: String = "https://"
    
    /// Host: phplaravel-574671-2962113.cloudwaysapps.com
    static let host: String = "phplaravel-574671-2962113.cloudwaysapps.com"

    /// Path: /api/v2/todos
    /// API 기본 경로
    static let path: String = "/api/v2/todos"
    
    /// Searchable Path: /api/v2/todos/search
    /// API 검색 경로
    static let searchPath: String = "/api/v2/todos/search"
    
    /// Postable Path: /api/v2/todos-json
    /// API 데이터 추가 경로(JSON)
    static let postPath: String = "/api/v2/todos-json"

    /// Accept: accept
    /// HTTP 헤더(KEY)
    static let accept: String = "accept"
    
    /// ContentType: Content-Type
    /// HTTP 헤더(KEY)
    static let contentType = "Content-Type"
    
    /// Application/JSON : application/json
    /// HTTP 헤더(VALUE)
    static let applicationJson = "application/json"
    
    /// multipartFromData : multipart/form-data
    /// HTTP 헤더(VALUE)
    static let multipartFromData = "multipart/form-data"
    
    /// applicationXw3FormUrlencoded : application/x-www-form-urlencoded
    /// HTTP 헤더(urlencoded) : VALUE
    static let applicationXw3FormUrlencoded = "application/x-www-form-urlencoded"

    /// xCsrfToken : X-CSRF-TOKEN
    /// HTTP 헤더(토큰 KEY)
//    static let xCsrfToken = "X-CSRF-TOKEN" // Deprecated
    
    /// API Token : q4PSs9s42v2gUQlUCIfrjs0U2TlhgiTG6mF5iXxf
    /// HTTP 헤더(토큰 VALUE)
//    static let token = "q4PSs9s42v2gUQlUCIfrjs0U2TlhgiTG6mF5iXxf" // Deprecated
}
