//
//  NetworkServiceProtocol.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

import Combine
import Foundation

protocol APIServiceProtocol {
    func request<T: NetworkAPIDefinition>(_ api: T) -> AnyPublisher<T.Response, Error>
    func requestPUT<T: NetworkAPIDefinition>(_ api: T) -> AnyPublisher<T.Response, Error> where T == PUTToDoAPI
}
