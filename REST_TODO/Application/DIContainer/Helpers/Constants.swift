//
//  Constants.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/19/24.
//

import Foundation

struct Constants {
    static let scheme: String = "https"
    static let host: String = "phplaravel-574671-2962113.cloudwaysapps.com"
    
    static let path: String = "/api/v2/todos"
    static let searchPath: String = "/api/v2/todos/search"
    static let postPath: String = "/api/v2/todos-json"
    
    static let accept: String = "accept"
    static let headerFieldKey = "Content-Type"
    static let headerFieldValue = "application/json"
    static let headerFieldMultiValue = "multipart/form-data"
}
