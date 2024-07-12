//
//  FilterViewController.swift
//  WhatToDo
//
//  Created by 준우의 MacBook 16 on 6/30/24.
//

import UIKit

final class FilterViewController: UIViewController {
    @IBOutlet weak var hiddenSegmentControl: UISegmentedControl!
    @IBOutlet weak var orderSegmentControl: UISegmentedControl!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var baseView: UIView!

    var selectedDone: String?
    var selectedOrder: String?
    var eventHandler: (() -> Void)?
}

// MARK: - View Life Cycle

extension FilterViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        let orderValue = SettingManager.shared.order
        orderSegmentControl.selectedSegmentIndex = convertOrderTag(value: orderValue)
        selectedOrder = orderValue

        let doneValue = SettingManager.shared.done
        hiddenSegmentControl.selectedSegmentIndex = convertDoneTag(value: doneValue)
        selectedDone = doneValue
    }
}

// MARK: - Setting Up UI

extension FilterViewController {
    private func setupUI() {
        baseView.layer.cornerRadius = 10
        confirmDoneSegmentControl()
        confirmOrderSegmentControl()
        confirmConfirmButton()
    }

    private func confirmConfirmButton() {
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton(_:)), for: .touchUpInside)
    }

    @objc private func didTapConfirmButton(_ sender: UIButton) {
        guard let done = selectedDone else { return }
        guard let order = selectedOrder else { return }

        SettingManager.saveDoneAndOrder(done: done, order: order)
        eventHandler?()
        dismiss(animated: true)
    }

    private func confirmDoneSegmentControl() {
        hiddenSegmentControl.addAction(UIAction(handler: { [weak self] action in
            guard let self = self else { return }
            let selectedIndex = self.hiddenSegmentControl.selectedSegmentIndex
            let selectedTitle = self.hiddenSegmentControl.titleForSegment(at: selectedIndex) ?? "No title"

            selectedDone = convertFilterOption(title: selectedTitle).rawValue
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 선택된 Index: \(selectedIndex), 선택된 Title: \(selectedTitle)")
        }), for: .valueChanged)
    }

    private func confirmOrderSegmentControl() {
        orderSegmentControl.addAction(UIAction(handler: { [weak self] action in
            guard let self = self else { return }
            let selectedIndex = self.orderSegmentControl.selectedSegmentIndex
            let selectedTitle = self.orderSegmentControl.titleForSegment(at: selectedIndex) ?? "No title"

            selectedOrder = convertOrderOption(title: selectedTitle).rawValue
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 선택된 Index: \(selectedIndex), 선택된 Title: \(selectedTitle)")
        }), for: .valueChanged)
    }

    private func convertFilterOption(title: String) -> Done {
        switch title {
        case "모두보기":
            return .all
        case "완료":
            return .onlyCompleted
        case "미완료":
            return .onlyNonCompleted
        default:
            return .all
        }
    }

    private func convertOrderOption(title: String) -> Order {
        switch title {
        case "내림차순":
            return .desc
        case "오름차순":
            return .asc
        default:
            return .desc
        }
    }

    private func convertDoneTag(value: String) -> Int {
        switch value {
        case Done.all.rawValue:
            return 0
        case Done.onlyCompleted.rawValue:
            return 1
        case Done.onlyNonCompleted.rawValue:
            return 2
        default:
            return 0
        }
    }

    private func convertOrderTag(value: String) -> Int {
        switch value {
        case Order.desc.rawValue:
            return 0
        case Order.asc.rawValue:
            return 1
        default:
            return 0
        }
    }
}
