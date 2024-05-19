//
//  ToDoCoordinator.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/18/24.
//

import UIKit

protocol ToDoCoordinatorDelegate {
    func goToDetailView(_ coordinator: ToDoCoordinator)
}

final class ToDoCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var delegate: ToDoCoordinatorDelegate?

    private var navigationController: UINavigationController!

    private let container = DIContainer.shared
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ToDoView()
        vc.viewModel = ToDoViewModel(apiService: container.resolve(type: APIServiceProtocol.self)!)
        vc.delegate = self
        self.navigationController.viewControllers = [vc]
    }
}

extension ToDoCoordinator: ToDoViewDelegate {
    func goToDetailView() {
        self.delegate?.goToDetailView(self)
    }
}
