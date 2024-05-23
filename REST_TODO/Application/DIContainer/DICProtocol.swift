//
//  DICProtocol.swift
//  MoCoDot
//
//  Created by 준우의 MacBook 16 on 2/8/24.
//

import Foundation

protocol DICProtocol {
    func register<T>(type: T.Type, service: Any)
    func resolve<T>(type: T.Type) -> T?
}
