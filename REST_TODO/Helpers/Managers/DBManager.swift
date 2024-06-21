//
//  DBManager.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/23/24.
//

import Foundation
import SQLite3

final class DBManager {
    init() {
        db = openDataBase()
        createFavoriteTable()
    }

    let dataPath: String = "Favorite"
    var db: OpaquePointer?

    /// DB 생성
    func openDataBase() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dataPath)

        var db: OpaquePointer?
        if sqlite3_open(filePath.path, &db) != SQLITE_OK {
            debugPrint("#### Cannot open DB.")
            return nil
        } else {
            print("#### DB successfully created.")
            return db
        }
    }

    /// 테이블 생성
    func createFavoriteTable() {
        let createTableString = """
            CREATE TABLE IF NOT EXISTS Favorite (
                id INTEGER PRIMARY KEY
            );
        """

        var createTableStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("#### Favorite table is created successfully.")
            } else {
                print("#### Favorite table creation failed.")
            }
        } else {
            print("#### Favorite table creation failed.")
        }

        sqlite3_finalize(createTableStatement)
    }

    /// 전체 Favorite 데이터 조회
    func getAllFavorite() -> [Favorite] {
        let queryStatementString = "SELECT * FROM Favorite;"
        var queryStatement: OpaquePointer?
        var favorites: [Favorite] = []

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)

                favorites.append(Favorite(id: Int(id)))
                print("#### Favorite Details: \(id)")
            }
        } else {
            print("#### SELECT statement is failed.")
        }
        sqlite3_finalize(queryStatement)
        return favorites
    }

    /// DB 데이터 삽입
    func insertFavorite(id: Int) -> Bool {
        let favorites = getAllFavorite()

        /// DB에 해당 ID 가 존재하는지 검사
        for favorite in favorites {
            if favorite.id == id {
                return false
            }
        }

        let insertStatementString = "INSERT INTO Favorite (id) VALUES (?);"
        var insertStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(id))

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("#### Favorite is created successfully.")
                sqlite3_finalize(insertStatement)
                return true
            } else {
                print("#### Could not add.")
                return false
            }
        } else {
            print("#### INSERT statement is failed.")
            return false
        }
    }

    /// DB에 해당 ID가 있는지 확인
    func fetchFavoriteByID(id: Int) -> Bool {
        let queryStatementString = "SELECT id FROM Favorite WHERE id = ?;"
        var queryStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(queryStatement, 1, Int32(id))

            if sqlite3_step(queryStatement) == SQLITE_ROW {
                sqlite3_finalize(queryStatement)
                return true
            } else {
                sqlite3_finalize(queryStatement)
                return false
            }
        } else {
            print("#### SELECT statement is failed.")
            return false
        }
    }

    /// DB에 해당하는 ID 있으면 삭제
    func deleteFavorite(id: Int) -> Bool {
        let deleteStatementString = "DELETE FROM Favorite WHERE id = ?;"
        var deleteStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))

            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("#### Favorite is deleted successfully.")
                sqlite3_finalize(deleteStatement)
                return true
            } else {
                print("#### Could not delete favorite.")
                sqlite3_finalize(deleteStatement)
                return false
            }
        } else {
            print("#### DELETE statement is failed.")
            return false
        }
    }
}
