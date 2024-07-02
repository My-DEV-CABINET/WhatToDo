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

    var selectedHidden: Bool? = nil
    var selectedOrder: Order = .desc
    var eventHandler: ((_ hidden: Bool?, _ order: Order) -> Void)?
}

// MARK: - View Life Cycle

extension FilterViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Setting Up UI

extension FilterViewController {
    private func setupUI() {
        baseView.layer.cornerRadius = 10
        confirmConfirmButton()
        confirmHiddenSegmentControl()
        confirmOrderSegmentControl()
    }

    private func confirmConfirmButton() {
        confirmButton.addAction(UIAction(handler: { [weak self] _ in
            guard let order = self?.selectedOrder else { return }

            self?.eventHandler?(self?.selectedHidden, order)
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
    }

    private func confirmHiddenSegmentControl() {
        hiddenSegmentControl.addAction(UIAction(handler: { [weak self] action in
            guard let self = self else { return }
            let selectedIndex = self.hiddenSegmentControl.selectedSegmentIndex
            let selectedTitle = self.hiddenSegmentControl.titleForSegment(at: selectedIndex) ?? "No title"

            selectedHidden = convertFilterOption(title: selectedTitle)
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 선택된 Index: \(selectedIndex), 선택된 Title: \(selectedTitle)")
        }), for: .valueChanged)
    }

    private func confirmOrderSegmentControl() {
        orderSegmentControl.addAction(UIAction(handler: { [weak self] action in
            guard let self = self else { return }
            let selectedIndex = self.orderSegmentControl.selectedSegmentIndex
            let selectedTitle = self.orderSegmentControl.titleForSegment(at: selectedIndex) ?? "No title"

            selectedOrder = convertOrderOption(title: selectedTitle)
            print("#### 클래스명: \(String(describing: type(of: self))), 함수명: \(#function), Line: \(#line), 선택된 Index: \(selectedIndex), 선택된 Title: \(selectedTitle)")
        }), for: .valueChanged)
    }

    private func convertFilterOption(title: String) -> Bool? {
        switch title {
        case "모두보기":
            return nil
        case "완료":
            return true
        case "미완료":
            return false
        default:
            return nil
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
}
