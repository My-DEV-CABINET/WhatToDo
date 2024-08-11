//
//  DBManager.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/23/24.
//

/// Realm
import RealmSwift

/// Apple
import Foundation

enum ReadDataType {
    case todoHistory // Todo 처리 내역
    case searchHistory // 검색결과 처리 내역
    case inquireHistory // 조회 결과 처리 내역
    case all // 전부 조회
}

final class DBManager {
    init(read: ReadDataType) {
        switch read {
        case .todoHistory:
            readTodoHistories()
        case .searchHistory:
            readSearchHistories()
        case .inquireHistory:
            readInquireHistories()
        case .all:
            readTodoHistories()
            readSearchHistories()
            readSearchHistories()
        }
    }

    let realm = try! Realm()

    /// 검색 결과 리스트
    var searchHistories: [SearchHistory] = []

    /// Todo 처리 내역 리스트
    var todoHistories: [TodoHistory] = []

    /// 조회 결과 리스트
    var inquireHistories: [InquireHistory] = []
}

// MARK: - Search History 관련 메서드

extension DBManager {
    // TODO: 검색어 입력
    func readSearchHistories() {
        searchHistories = Array(realm.objects(SearchHistory.self))
    }

    func createSearchHistory(name: String, createdDate: Date) {
        let searchHistory = SearchHistory(value: ["name": name, "created": createdDate])

        if !searchHistories.contains(where: { $0.name == name }) {
            do {
                try realm.write {
                    realm.add(searchHistory)
                }
                readSearchHistories()
            } catch {
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: SearchHistory 데이터를 저장하는데 실패하였습니다.")
            }
        }
    }

    func deleteSearchHistory(name: String) {
        do {
            if let searchHistory = realm.objects(SearchHistory.self).filter("name == %@", name).first {
                try realm.write {
                    realm.delete(searchHistory)
                }
                readSearchHistories()
            } else {
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: 해당 todoID를 가진 InquireHistory 데이터를 찾을 수 없습니다.")
            }
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: SearchHistory 데이터를 삭제하는데 실패하였습니다.")
        }
    }

    func deleteAllSearhHistory() {
        do {
            try realm.write {
                let allSearchHistory = realm.objects(SearchHistory.self)
                realm.delete(allSearchHistory)
            }
            readSearchHistories()
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: SearchHistory 데이터 전체 삭제하는데 실패하였습니다.")
        }
    }
}

// MARK: - Todo History 관련 메서드

extension DBManager {
    // TODO: Todo 할일 처리
    func readTodoHistories() {
        todoHistories = Array(realm.objects(TodoHistory.self))
    }

    func createTodoHistory(name: String, createdDate: Date) {
        let todoHistory = TodoHistory(value: ["name": name, "created": createdDate])

        do {
            try realm.write {
                realm.add(todoHistory)
            }
            readTodoHistories()
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: TodoHistory 데이터를 저장하는데 실패하였습니다.")
        }
    }

    // 할일 내역 알림 읽음 처리
    func updateAllTodoHistory() {
        do {
            try realm.write {
                let allTodoHistory = realm.objects(TodoHistory.self)

                for todoHistory in allTodoHistory {
                    todoHistory.isRead = true
                }
            }
            readTodoHistories()
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: TodoHistory 전체 데이터를 읽음 변경하는데 실패하였습니다.")
        }
    }

    func deleteTodoHistory(name: String) {
        do {
            if let todoHistory = realm.objects(TodoHistory.self).filter("name == %@", name).first {
                try realm.write {
                    realm.delete(todoHistory)
                }
                readTodoHistories()
            } else {
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: 해당 Name을 가진 TodoHistory 데이터를 찾을 수 없습니다.")
            }
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: TodoHistory 데이터를 삭제하는데 실패하였습니다.")
        }
    }
}

// MARK: - Inquire History 관련 메서드

extension DBManager {
    // TODO: 조회 처리
    func readInquireHistories() {
        inquireHistories = Array(realm.objects(InquireHistory.self))
        print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: \(inquireHistories)")
    }

    func createInquireHistory(id: Int) {
        let inquireHistory = InquireHistory(value: ["todoID": id])

        do {
            try realm.write {
                realm.add(inquireHistory)
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: \(inquireHistories)")
            }
            readInquireHistories()
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: InquireHistory 데이터를 저장하는데 실패하였습니다. 에러: \(error.localizedDescription)")
        }
    }

    func deleteInquireHistory(todoId: Int) {
        do {
            if let inquireHistory = realm.objects(InquireHistory.self).filter("todoID == %@", todoId).first {
                try realm.write {
                    realm.delete(inquireHistory)
                }
                readInquireHistories()
            } else {
                print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: 해당 todoID를 가진 InquireHistory 데이터를 찾을 수 없습니다.")
            }
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: InquireHistory 데이터를 삭제하는데 실패하였습니다.")
        }
    }
}
