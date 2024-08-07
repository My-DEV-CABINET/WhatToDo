//
//  Constants.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/19/24.
//

import Foundation

struct Constants {
    static var scheme: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "SCHEME") as? String else { fatalError("SCHEME not found in plist") }
        guard let replaceResult = result.removingPercentEncoding else { fatalError("SCHEME not replace") }
        return replaceResult
    }

    static var host: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "HOST") as? String else { fatalError("HOST not found in plist") }
        return result
    }

    static var path: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "PATH") as? String else { fatalError("PATH not found in plist") }
        return result
    }

    static var searchPath: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "SEARCH_PATH") as? String else { fatalError("SEARCH_PATH not found in plist") }
        return result
    }

    static var postPath: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "POST_PATH") as? String else { fatalError("POST_PATH not found in plist") }
        return result
    }

    static var accept: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "ACCEPT") as? String else { fatalError("ACCEPT not found in plist") }
        return result
    }

    static var contentType: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "CONTENT_TYPE") as? String else { fatalError("CONTENT_TYPE not found in plist") }
        return result
    }

    static var applicationJson: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "APPLICATION_JSON") as? String else { fatalError("APPLICATION_JSON not found in plist") }
        return result
    }

    static var multipartFromData: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "MULTIPART_FROM_DATA") as? String else { fatalError("MULTIPART_FROM_DATA not found in plist") }
        return result
    }

    static var applicationXw3FormUrlencoded: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "APPLICATION_X_WWW_FORM_URLENCODED") as? String else { fatalError("APPLICATION_X_WWW_FORM_URLENCODED not found in plist") }
        return result
    }

    static var xCsrfToken: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "X_CSRF_TOKEN") as? String else { fatalError("X_CSRF_TOKEN not found in plist") }
        return result
    }

    static var token: String {
        guard let result = Bundle.main.object(forInfoDictionaryKey: "TOKEN") as? String else { fatalError("TOKEN not found in plist") }
        return result
    }
}
