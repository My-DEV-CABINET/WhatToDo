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
        self.registerService()
        self.showToDoView()
    }

    private func registerService() {
        self.container.register(type: APIServiceProtocol.self, service: APIService())
    }

    private func showToDoView() {
        let coordinator = ToDoCoordinator(navigationController: self.navigationController)
        coordinator.delegate = self
        coordinator.start()
        self.childCoordinators.append(coordinator)
    }

    func goToDetailView(_ coordinator: ToDoCoordinator) {
        let vc = DetailToDoView()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        navigationController.isNavigationBarHidden = false
        self.navigationController.present(navigationController, animated: true)
    }
}
