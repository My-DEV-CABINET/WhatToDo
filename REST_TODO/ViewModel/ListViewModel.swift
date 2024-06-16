////
////  ToDoViewModel.swift
////  REST_TODO
////
////  Created by 준우의 MacBook 16 on 5/18/24.
////
//
// import Combine

/// Network
import Alamofire

/// Rx
import RxCocoa
import RxRelay
import RxSwift

/// Apple
import Foundation

final class ListViewModel {
    var todoBehaviorSubject: BehaviorSubject<[ToDoData]> = .init(value: [])
    var disposeBag = DisposeBag()

    let dbManager = DBManager()
    private var todos: [ToDoData] = []
    var isHidden: Bool = true

    /// API Query
    private var page = 1
    private var filter = Filter.createdAt.rawValue
    private var orderBy = Order.desc.rawValue
    private var perPage = 10
    private var isDone: Bool? // 완료 여부

    /// 페이지네이션 이벤트 처리
    let paginationRelay: BehaviorRelay<Bool> = .init(value: false)

    /// 스크롤 이벤트 처리: 스크롤이 끝에 도달했는지 파악
    let scrollEndRelay: BehaviorRelay<Bool> = .init(value: false)

    /// 완료 숨기기 버튼 이벤트 처리
    let hiddenRelay: BehaviorRelay<Bool> = .init(value: false)

    /// 페이지네이션 이벤트 유효성 검사
    var validPagination: Driver<Bool> {
        return paginationRelay
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
    }

    /// 완료 숨기기 이벤트 유효성 검사
    var validHidden: Driver<String> {
        return hiddenRelay
            .distinctUntilChanged()
            .scan(false) { isHidden, _ in !isHidden }
            .map { isHidden in
                return isHidden ? "완료 숨기기" : "완료 보이기"
            }
            .asDriver(onErrorJustReturn: "완료 숨기기")
    }

    /// Todo 데이터 10개 호출 - 완료 숨김 처리 X
    func requestGETTodos(completion: @escaping () -> Void?) {
        let utilityQueue = DispatchQueue.global(qos: .utility)
        let url = Constants.scheme + Constants.host + Constants.path
        var parameters: [String: String] = [:]

        let manager = NetworkReachabilityManager(host: url)

        if hiddenRelay.value == false {
            /// 완료 여부 보이기
            parameters = [
                "page": page.description,
                "filter": filter,
                "order_by": orderBy,
                "per_page": perPage.description
            ]
        } else {
            /// 완료 여부 숨기기
            parameters = [
                "page": page.description,
                "filter": filter,
                "order_by": orderBy,
                "is_done": false.description,
                "per_page": perPage.description
            ]
        }

        let headers: HTTPHeaders = [
            .accept("\(Constants.applicationJson)")
        ]

        AF.request(
            url,
            method: .get,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder(destination: .queryString),
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
        .responseDecodable(of: ToDos.self, queue: utilityQueue) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let value):
                guard let data = value.data else { return }
                self.todos = data
                self.todoBehaviorSubject.onNext(data)
                completion()
            case .failure(let error):

                if manager?.flags?.isEmpty == false {
                    print("#### Network Error: \(error)")
                }
            }
        }
    }

    /// Todo 데이터 검색
    func searchTodo(query: String, completion: @escaping ([ToDoData]) -> Void) {
        let utilityQueue = DispatchQueue.global(qos: .utility)
        let url = Constants.scheme + Constants.host + Constants.searchPath
        let headers: HTTPHeaders = [
            Constants.accept: Constants.applicationJson
        ]
        var parameters: [String: String] = [:]

        if hiddenRelay.value == false {
            /// 완료 여부 보이기
            parameters = [
                "query": query,
                "page": page.description,
                "filter": filter,
                "order_by": orderBy,
                "per_page": perPage.description
            ]
        } else {
            /// 완료 여부 숨기기
            parameters = [
                "query": query,
                "page": page.description,
                "filter": filter,
                "order_by": orderBy,
                "is_done": false.description,
                "per_page": perPage.description
            ]
        }

        AF.request(
            url,
            method: .get,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder(destination: .queryString),
            headers: headers,
            interceptor: .retryPolicy
        )
        .cacheResponse(using: .cache)
        .redirect(using: .follow)
        .validate()
        // curl 표시
        .cURLDescription { description in
            print("#### curl -v : \(description)")
        }
        // 요청하는 URL 전체 주소 표시
        .onURLRequestCreation { request in
            print("#### 전체 URL은 \(request)")
        }
        .responseDecodable(of: ToDos.self, queue: utilityQueue) { [weak self] response in
            guard let self = self else { return }

            switch response.result {
            case .success(let value):
                guard let data = value.data else { return }
                self.todos = data
                completion(self.todos)
                self.todoBehaviorSubject.onNext(data)
            case .failure(let error):
                print("#### Search Error: \(error)")
                completion([])
                self.todoBehaviorSubject.onNext([])
            }
        }
    }

    /// Todo 데이터 삭제
    func removeTodo(data: ToDoData, completion: @escaping () -> Void) {
        let utilityQueue = DispatchQueue.global(qos: .utility)
        guard let id = data.id else { return }
        let url = Constants.scheme + Constants.host + Constants.path + "/\(id)"
        let headers: HTTPHeaders = [
            .accept("\(Constants.applicationJson)")
        ]

        AF.request(
            url,
            method: .delete,
            headers: headers,
            interceptor: .retryPolicy
        )
        .validate()
        .cacheResponse(using: .cache)
        .redirect(using: .follow)
        .validate(statusCode: 200 ..< 300)
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
                if let index = self.todos.firstIndex(where: { $0.id == data.id }) {
                    self.todos.remove(at: index)
                    self.todoBehaviorSubject.onNext(self.todos)
                    completion()
                }
            case .failure(let error):
                print("#### Delete Error: \(error)")
            }
        }
    }

    /// Todo 데이터 수정
    func editTodo(title: String, isDone: Bool, id: Int) {
        let utilityQueue = DispatchQueue.global(qos: .utility)
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
            case .success(let value):
                guard let data = value.data else { return }

                if let index = self.todos.firstIndex(where: { $0.id == id }) {
                    self.todos[index] = data
                    self.todoBehaviorSubject.onNext(self.todos)
                }
            case .failure(let error):
                print("#### Edit Error: \(error)")
            }
        }
    }

    // Todos 데이터 추가 요청
    func requestMoreTodos(completion: @escaping (Bool) -> Void) {
        let utilityQueue = DispatchQueue.global(qos: .utility)
        let url = Constants.scheme + Constants.host + Constants.path
        var parameters: [String: String] = [:]

        if hiddenRelay.value == false {
            /// 완료 여부 보이기
            parameters = [
                "page": page.description,
                "filter": filter,
                "order_by": orderBy,
                "per_page": perPage.description
            ]
        } else {
            /// 완료 여부 숨기기
            parameters = [
                "page": page.description,
                "filter": filter,
                "order_by": orderBy,
                "is_done": false.description,
                "per_page": perPage.description
            ]
        }
        let headers: HTTPHeaders = [
            .accept("\(Constants.applicationJson)")
        ]

        AF.request(
            url,
            method: .get,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder(destination: .queryString),
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
        .responseDecodable(of: ToDos.self, queue: utilityQueue) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let value):
                guard let data = value.data else { return }
                self.todos += data
                self.todoBehaviorSubject.onNext(self.todos)
                completion(true)
            case .failure(let error):
                completion(false)
                if error.isSessionTaskError == true {
                    print("#### Pagination Error: \(error)")
                }
            }
        }
    }

    // 검색 데이터 추가 요청
    func requestMoreQueryTodos(query: String, completion: @escaping (Bool) -> Void) {
        let utilityQueue = DispatchQueue.global(qos: .utility)
        let url = Constants.scheme + Constants.host + Constants.searchPath
        let headers: HTTPHeaders = [
            Constants.accept: Constants.applicationJson
        ]
        var parameters: [String: String] = [:]

        if hiddenRelay.value == false {
            /// 완료 여부 보이기
            parameters = [
                "query": query,
                "page": page.description,
                "filter": filter,
                "order_by": orderBy,
                "per_page": perPage.description
            ]
        } else {
            /// 완료 여부 숨기기
            parameters = [
                "query": query,
                "page": page.description,
                "filter": filter,
                "order_by": orderBy,
                "is_done": false.description,
                "per_page": perPage.description
            ]
        }

        AF.request(
            url,
            method: .get,
            parameters: parameters,
            encoder: URLEncodedFormParameterEncoder(destination: .queryString),
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
        .responseDecodable(of: ToDos.self, queue: utilityQueue) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let value):
                guard let data = value.data else { return }
                self.todos += data
                self.todoBehaviorSubject.onNext(self.todos)
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: \(self.todos.count)")
                completion(true)
            case .failure(let error):
                completion(false)
                print("#### Search Pagination Error: \(error.isResponseSerializationError)")
            }
        }
    }
}

// MARK: - Pagination 처리 모음

extension ListViewModel {
    func increasePage() {
        page += 1
    }

    func resetPage() {
        page = 1
    }
}