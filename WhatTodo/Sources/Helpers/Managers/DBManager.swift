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

final class DBManager {
    // Todo - 1 : 검색어 입력 저장(C, R, D)
    // Todo - 2 : Todo 할일 처리 내역 저장(C, R, D)
    // Todo - 3 : 조회 처리(C, R, D)

    init() {
        readTodoHistories()
        readSearchHistories()
        readInquireHistories()
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

        do {
            try realm.write {
                realm.add(searchHistory)
            }
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: SearchHistory 데이터를 저장하는데 실패하였습니다.")
        }
    }

    func deleteSearchHistory(searchHistory: SearchHistory) {
        do {
            try realm.write {
                realm.delete(searchHistory)
            }
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: SearchHistory 데이터를 삭제하는데 실패하였습니다.")
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
        } catch {
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 출력 Log: TodoHistory 데이터를 저장하는데 실패하였습니다.")
        }
    }

    func deleteTodoHistory(todoHistory: TodoHistory) {
        do {
            try realm.write {
                realm.delete(todoHistory)
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
