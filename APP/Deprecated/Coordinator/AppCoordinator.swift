////
////  AppCoordinator.swift
////  REST_TODO
////
////  Created by 준우의 MacBook 16 on 5/18/24.
////
//
//import UIKit
//
//final class AppCoordinator: Coordinator {
//    var childCoordinators: [Coordinator] = []
//    private var navigationController: UINavigationController!
//
//    private let container = DIContainer.shared
//
//    init(navigationController: UINavigationController) {
//        self.navigationController = navigationController
//    }
//
//    func start() {
//        self.registerService()
//        self.showToDoView()
//    }
//
//    private func registerService() {
//        self.container.register(type: APIServiceProtocol.self, service: APIService())
//    }
//
//    private func showToDoView() {
//        let coordinator = ToDoCoordinator(navigationController: self.navigationController)
//        coordinator.delegate = self
//        coordinator.start()
//        self.childCoordinators.append(coordinator)
//    }
//}
//
//// MARK: - ToDoCoordinatorDelegate
//
//extension AppCoordinator: ToDoCoordinatorDelegate {
//    func goToDetailViewWithAdd(_ coordinator: ToDoCoordinator) {
//        let coordinator = ToDoCoordinator(navigationController: self.navigationController)
//        coordinator.delegate = self
//        coordinator.pushDetailViewWithAdd()
//        self.childCoordinators.append(coordinator)
//    }
//
//    func goToDetailViewWithEdit(_ coordinator: ToDoCoordinator, id: Int) {
//        let coordinator = ToDoCoordinator(navigationController: self.navigationController)
//        coordinator.delegate = self
//        coordinator.pushDetailViewWithEdit(id: id)
//        self.childCoordinators.append(coordinator)
//    }
//
//    func dismissView(_ coordinator: ToDoCoordinator) {
//        let coordinator = ToDoCoordinator(navigationController: self.navigationController)
//        coordinator.delegate = self
//        coordinator.start()
//        coordinator.popView()
//    }
//}
