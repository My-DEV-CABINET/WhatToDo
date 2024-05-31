////
////  ToDoCoordinator.swift
////  REST_TODO
////
////  Created by 준우의 MacBook 16 on 5/18/24.
////
//
//import UIKit
//
//protocol ToDoCoordinatorDelegate {
//    func goToDetailViewWithAdd(_ coordinator: ToDoCoordinator)
//    func goToDetailViewWithEdit(_ coordinator: ToDoCoordinator, id: Int)
//    func dismissView(_ coordinator: ToDoCoordinator)
//}
//
//final class ToDoCoordinator: Coordinator {
//    var childCoordinators: [Coordinator] = []
//    var delegate: ToDoCoordinatorDelegate?
//
//    private var navigationController: UINavigationController!
//
//    private let container = DIContainer.shared
//
//    init(navigationController: UINavigationController) {
//        self.navigationController = navigationController
//    }
//
//    func start() {
//        let vc = ToDoView()
//        vc.viewModel = ToDoViewModel(apiService: self.container.resolve(type: APIServiceProtocol.self)!)
//        vc.delegate = self
//        self.navigationController.viewControllers = [vc]
//    }
//
//    func pushDetailViewWithAdd() {
//        let vc = DetailToDoView()
//        vc.viewModel = DetailToDoViewModel(apiService: self.container.resolve(type: APIServiceProtocol.self)!)
//        vc.delegate = self
//        vc.viewModel.currentUserAction = .add
//
//        let rootNavigationViewController = UINavigationController(rootViewController: vc)
//        rootNavigationViewController.modalPresentationStyle = .formSheet
//        rootNavigationViewController.isNavigationBarHidden = false
//
//        self.navigationController.present(rootNavigationViewController, animated: true)
//    }
//
//    func pushDetailViewWithEdit(id: Int) {
//        let vc = DetailToDoView()
//        vc.viewModel = DetailToDoViewModel(apiService: self.container.resolve(type: APIServiceProtocol.self)!)
//        vc.delegate = self
//        vc.viewModel.id = id
//        vc.viewModel.currentUserAction = .edit
//
//        let rootNavigationViewController = UINavigationController(rootViewController: vc)
//        rootNavigationViewController.modalPresentationStyle = .formSheet
//        rootNavigationViewController.isNavigationBarHidden = false
//
//        self.navigationController.present(rootNavigationViewController, animated: true)
//    }
//
//    func popView() {
//        self.navigationController.dismiss(animated: true)
//    }
//}
//
//// MARK: - ToDoViewDelegate
//
//extension ToDoCoordinator: ToDoViewDelegate {
//    func goToDetailViewWithAdd() {
//        self.delegate?.goToDetailViewWithAdd(self)
//    }
//
//    func goToDetailViewWithEdit(id: Int) {
//        self.delegate?.goToDetailViewWithEdit(self, id: id)
//    }
//
//    func dismissView() {
//        self.delegate?.dismissView(self)
//    }
//}
