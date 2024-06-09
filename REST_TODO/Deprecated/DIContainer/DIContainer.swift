//
//  DIContainer.swift
//  MoCoDot
//
//  Created by 준우의 MacBook 16 on 2/8/24.
//

import Foundation

final class DIContainer: DICProtocol {
    static let shared = DIContainer()

    private var dependencies: [String: Any] = [:]

    func register<T>(type: T.Type, service: Any) {
        let key = String(describing: type)
        dependencies[key] = service
    }

    func resolve<T>(type: T.Type) -> T? {
        let key = String(describing: type)
        return dependencies[key] as? T
    }

    private init() {}
}
