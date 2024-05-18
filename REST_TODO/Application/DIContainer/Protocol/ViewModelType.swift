//
//  ViewModelType.swift
//  RGRG
//
//  Created by 준우의 MacBook 16 on 4/29/24.
//

import Combine
import Foundation

protocol ViewModelType {
    associatedtype Input // View -> ViewModel
    associatedtype Output // ViewModel -> View

    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
