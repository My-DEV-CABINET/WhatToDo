////
////  DetailToDoViewModel.swift
////  REST_TODO
////
////  Created by 준우의 MacBook 16 on 5/21/24.
////
//

/// Rx
import RxCocoa
import RxSwift

/// Network
import Alamofire

/// Apple
import Foundation

final class AddViewModel {
    var disposeBag = DisposeBag()

    var todo: ToDoData?
    var userAction: UserAction = .add
    let textViewInputRelay: BehaviorRelay<String> = BehaviorRelay(value: "")

    func createTodo(title: String, isDone: Bool, completion: @escaping (Bool) -> Void) {
        let utilityQueue = DispatchQueue.global(qos: .utility)
        let url = Constants.scheme + Constants.host + Constants.postPath
        let headers: HTTPHeaders = [Constants.accept: Constants.applicationJson, Constants.contentType: Constants.applicationJson]
        let parameters: [String: String] = [
            "title": title,
            "is_done": isDone.description
        ]

        AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoder: JSONParameterEncoder.default,
            headers: headers,
            interceptor: .retryPolicy
        )
        .cacheResponse(using: .cache)
        .redirect(using: .follow)
        .validate(statusCode: 200 ..< 500)
        // curl 표시
        .cURLDescription { description in
            print("#### curl -v : \(description)")
        }
        // 요청하는 URL 전체 주소 표시
        .onURLRequestCreation { request in
            print("#### 전체 URL은 \(request)")
        }
        .responseDecodable(of: ToDo.self, queue: utilityQueue) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Error: \(error)")
                completion(false)
            }
        }
    }

    func editTodo(title: String, isDone: Bool, completion: @escaping (Bool) -> Void) {
        let utilityQueue = DispatchQueue.global(qos: .utility)
        guard let id = todo?.id else { return }
        let url = Constants.scheme + Constants.host + Constants.path + "/\(id)"
        let headers: HTTPHeaders = [
            Constants.accept: Constants.applicationJson,
            Constants.contentType: Constants.applicationXw3FormUrlencoded
        ]
        let parameters: [String: String] = [
            "title": title,
            "is_done": isDone.description
        ]

        AF.request(
            url,
            method: .put,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers,
            interceptor: .retryPolicy
        )
        .cacheResponse(using: .cache)
        .redirect(using: .follow)
        .validate(statusCode: 200 ..< 500)
        // curl 표시
        .cURLDescription { description in
            print("#### curl -v : \(description)")
        }
        // 요청하는 URL 전체 주소 표시
        .onURLRequestCreation { request in
            print("#### 전체 URL은 \(request)")
        }
        .responseDecodable(of: ToDo.self, queue: utilityQueue) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Error: \(error)")
                completion(false)
            }
        }
    }
}