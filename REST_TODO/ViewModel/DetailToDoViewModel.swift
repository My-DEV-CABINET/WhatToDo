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

final class DetailToDoViewModel {
    var disposeBag = DisposeBag()

    var todo: ToDoData?
    var userAction: UserAction = .edit
    var previousText = ""

    private let utilityQueue = DispatchQueue.global(qos: .utility)

    let textInputRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    let buttonTapRelay = PublishRelay<Int>()
    let editTapRelay = PublishRelay<Void>()

    var textValidDriver: Driver<Bool> {
        return textInputRelay
            .map { $0.count > 5 }
            .asDriver(onErrorJustReturn: false)
    }

    var isHiddenValid: Driver<Bool> {
        return editTapRelay
            .filter { self.userAction == .edit }
            .scan(false) { isHidden, _ in !isHidden }
            .asDriver(onErrorJustReturn: false)
    }

    func createTodo(title: String, isDone: Bool, completion: @escaping (Bool) -> Void) {
        // POST
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
        // PUT
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

//
// final class DetailToDoViewModel: ViewModelType {
//    let apiService: APIServiceProtocol
//
//    init(apiService: APIServiceProtocol) {
//        self.apiService = apiService
//    }
//
//    private let output: PassthroughSubject<Output, Never> = .init()
//    private var subcriptions = Set<AnyCancellable>()
//
//    enum Input {
//        case requestGETToDo
//        case requestPOSTToDoAPI(title: String, isDone: Bool)
//        case requestPUTToDoAPI(title: String, isDone: Bool)
//    }
//
//    enum Output {
//        case getToDo(todo: ToDoData)
//        case dismissView
//        case sendError(error: Error)
//    }
//
//    var id: Int?
//    var currentUserAction: UserAction = .add
// }
//
//// MARK: - API 및 Output
//
// extension DetailToDoViewModel {
//    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
//        input.sink { [weak self] event in
//            switch event {
//            case .requestGETToDo:
//                self?.requestGETToDo()
//
//            case .requestPOSTToDoAPI(let title, let isDone):
//                self?.requestPOSTToDoAPI(title: title, isDone: isDone)
//
//            case .requestPUTToDoAPI(let title, let isDone):
//                self?.requestPUTToDoAPI(title: title, isDone: isDone)
//            }
//        }
//        .store(in: &subcriptions)
//
//        return output.eraseToAnyPublisher()
//    }
//
//    /// 단일 ToDo 데이터 조회
//    private func requestGETToDo() {
//        guard let id = id else { return }
//        let dto = ToDoIDDTO(id: id.description)
//        guard let api = APICase.getTodo(dto: dto).api as? GETTodoAPI else { return }
//
//        apiService.request(api)
//            .sink { completion in
//                switch completion {
//                case .failure(let error):
//                    print("#### Error fetching todo: \(error)")
//                    self.output.send(.sendError(error: error))
//                case .finished:
//                    print("#### Finished \(completion)")
//                }
//            } receiveValue: { [weak self] response in
//                guard let data = response.data else { return }
//                self?.output.send(.getToDo(todo: data))
//            }
//            .store(in: &subcriptions)
//    }
//
//    /// ToDo 데이터 생성
//    /// - Parameters:
//    ///   - title: View's TextField Text
//    ///   - isDone: View's UISwitch isOn
//    private func requestPOSTToDoAPI(title: String, isDone: Bool) {
//        let dto = ToDoBodyDTO(title: title, is_Done: isDone)
//        guard let api = APICase.postTodo(dto: dto).api as? POSTToDoAPI else { return }
//
//        apiService.request(api)
//            .sink { completion in
//                switch completion {
//                case .failure(let error):
//                    print("#### Error Posting todo: \(error)")
//                    self.output.send(.sendError(error: error))
//                case .finished:
//                    print("#### Finished \(completion)")
//                }
//            } receiveValue: { [weak self] response in
//                guard let self = self else { return }
//                output.send(.dismissView)
//            }
//            .store(in: &subcriptions)
//    }
//
//    /// ToDo 데이터 업데이트
//    /// - Parameter todo: 변경할 ToDo 데이터
//    private func requestPUTToDoAPI(title: String, isDone: Bool) {
//        guard let id = id else { return }
//
//        let idDTO = ToDoIDDTO(id: id.description)
//        let bodyDTO = ToDoBodyDTO(title: title, is_Done: isDone)
//        guard let api = APICase.putToDo(idDTO: idDTO, bodyDTO: bodyDTO).api as? PUTToDoAPI else { return }
//
//        apiService.requestWithEncoded(api)
//            .sink { completion in
//                switch completion {
//                case .failure(let error):
//                    print("#### Error updating todo: \(error)")
//                    self.output.send(.sendError(error: error))
//                case .finished:
//                    print("#### Finished \(completion)")
//                }
//            } receiveValue: { [weak self] _ in
//                guard let self = self else { return }
//                output.send(.dismissView)
//            }
//            .store(in: &subcriptions)
//    }
// }
