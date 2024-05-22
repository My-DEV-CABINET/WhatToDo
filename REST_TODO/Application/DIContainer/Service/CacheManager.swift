//
//  CacheManager.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/23/24.
//

import Foundation

final class CacheManager {
    static let shared = NSCache<NSString, NSString>()
    private init() {}
}
