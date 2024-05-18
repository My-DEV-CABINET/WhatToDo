//
//  AppCoordinator.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

import UIKit

final class AppCoordinator: Coordinator, ToDoCoordinatorDelegate {
    var childCoordinators: [Coordinator] = []
    private var navigationController: UINavigationController!
    
    private let container = DIContainer.shared
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        self.showToDoView()
    }

    private func showToDoView() {
        let coordinator = ToDoCoordinator(navigationController: self.navigationController)
        coordinator.delegate = self
        coordinator.start()
        self.childCoordinators.append(coordinator)
    }

    func didTapToDoRow(_ coordinator: ToDoCoordinator) {
        //
    }
}
