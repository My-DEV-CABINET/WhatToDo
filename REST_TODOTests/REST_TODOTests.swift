//
//  REST_TODOTests.swift
//  REST_TODOTests
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

@testable import REST_TODO
import XCTest

struct ToDoDataDTO: Codable {
    let title: String
    let email: String
    let content: String
}

final class REST_TODOTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // 테스트 준비 코드
    }

    override func tearDown() {
        // 테스트 종료 코드
        super.tearDown()
    }

    func testRequestTodos() {
        let expectation = self.expectation(description: "Fetching todos from API")

        let baseUrl = "https://phplaravel-574671-2962113.cloudwaysapps.com"
        var components = URLComponents(string: baseUrl)
        components?.path = "/api/v2/mocks"
        components?.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "order_by", value: "desc"),
            URLQueryItem(name: "per_page", value: "10")
        ]

        guard let url = components?.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }

            if let data = data {
                do {
                    let todos = try JSONDecoder().decode(ToDos.self, from: data)
                    XCTAssertEqual(todos.data?.count, 10, "테스트 성공: 10개 호출")

                } catch {
                    print("Failed to decode response: \(error)")
                }
            }

            expectation.fulfill()
        }
        task.resume()

        waitForExpectations(timeout: 10, handler: nil) // 비동기 작업을 기다림
    }

    func testRequestTodoWithID() {
        let expectation = self.expectation(description: "Fetching todos from API")
        let id = 154

        let baseUrl = "https://phplaravel-574671-2962113.cloudwaysapps.com"
        var components = URLComponents(string: baseUrl)
        components?.path = "/api/v2/mocks"
        components?.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "order_by", value: "desc"),
            URLQueryItem(name: "per_page", value: "1"),
            URLQueryItem(name: "id", value: "\(id)")
        ]

        guard let url = components?.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }

            if let data = data {
                do {
                    let todos = try JSONDecoder().decode(ToDos.self, from: data)
                    XCTAssertEqual(todos.data?.count, 1, "테스트 성공: 1개 호출")

                } catch {
                    print("Failed to decode response: \(error)")
                }
            }

            expectation.fulfill()
        }
        task.resume()

        waitForExpectations(timeout: 10, handler: nil) // 비동기 작업을 기다림
    }

    func testPostTodo() {
        let expectation = self.expectation(description: "Fetching todos from API")

        let newToDo = ToDoDataDTO(title: "Hello World", email: "test123@gmail.com", content: "동해물과 백두산이 마르고 닳도록...")
        guard let httpBody = try? JSONEncoder().encode(newToDo) else {
            return
        }

        let baseUrl = "https://phplaravel-574671-2962113.cloudwaysapps.com"
        var components = URLComponents(string: baseUrl)
        components?.path = "/api/v2/mocks"

        guard let url = components?.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }

            do {
                let addedTodo = try JSONDecoder().decode(ToDos.self, from: data)
                print("#### \(addedTodo)")
            } catch {
                print("Failed to decode response: \(error)")
            }
        }
        task.resume()

        expectation.fulfill()
        waitForExpectations(timeout: 10, handler: nil) // 비동기 작업을 기다림
    }
}
