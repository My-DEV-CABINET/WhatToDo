//
//  ToDoCell.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/17/24.
//

import UIKit

enum Identifier: String {
    case todoCell = "ToDoCell"
}

final class ToDoCell: UITableViewCell {
    static let identifier = Identifier.todoCell.rawValue

    var checkBox = UIButton(frame: .zero)
    var titleLabel = UILabel(frame: .zero)
    var dateLabel = UILabel(frame: .zero)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setting ToDoCell

extension ToDoCell {
    private func setupUI() {
        addView()
        configureTitleLabel()
    }

    private func addView() {
        [checkBox, titleLabel, dateLabel].forEach { contentView.addSubview($0) }
    }

    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.textColor = .black

        let constranits = [
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            titleLabel.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -10)
        ]

        NSLayoutConstraint.activate(constranits)
    }
}
