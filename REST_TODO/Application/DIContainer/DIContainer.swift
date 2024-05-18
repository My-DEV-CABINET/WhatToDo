//
//  DIContainer.swift
//  MoCoDot
//
//  Created by 준우의 MacBook 16 on 2/8/24.
//

import Foundation

final class DIContainer: DICProtocol {
    static let shared = DIContainer()

    // 의존성을 등록할 딕셔너리를 선언합니다.
    private var dependencies: [String: Any] = [:]

    // 의존성을 등록하는 메서드
    func register<T>(type: T.Type, service: Any) {
        let key = String(describing: type)
        dependencies[key] = service
    }

    // 의존성을 해결하는 메서드
    func resolve<T>(type: T.Type) -> T? {
        let key = String(describing: type)
        return dependencies[key] as? T
    }

    private init() {} // 외부에서 추가 생성 방지
}
