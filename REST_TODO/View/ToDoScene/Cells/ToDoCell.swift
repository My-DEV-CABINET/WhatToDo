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

protocol ToDoCellDelegate {
    func didTapCheckBox(id: Int)
    func didTapFavoriteBox(id: Int)
}

final class ToDoCell: UITableViewCell {
    static let identifier = Identifier.todoCell.rawValue

    var delegate: ToDoCellDelegate?

    var checkBox = UIButton(frame: .zero)
    var favoriteButton = UIButton(frame: .zero)
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

        configureCheckBox()
        configureDateLabel()
        configureTitleLabel()
        configureFavoriteButton()
    }

    private func addView() {
        [checkBox, titleLabel, dateLabel, favoriteButton].forEach { contentView.addSubview($0) }
    }

    private func configureCheckBox() {
        checkBox.translatesAutoresizingMaskIntoConstraints = false

        checkBox.tintColor = .black
        checkBox.layer.cornerRadius = 10
        checkBox.layer.masksToBounds = true

        let constraints = [
            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkBox.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            checkBox.widthAnchor.constraint(equalToConstant: 30),
            checkBox.heightAnchor.constraint(equalToConstant: 30)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.textColor = .systemGray
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.numberOfLines = 2

        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -10),
            titleLabel.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -80)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureDateLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.textColor = .systemGray2
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)

        let constraints = [
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            dateLabel.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 10),
            dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 67),
            dateLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 10)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureFavoriteButton() {
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        favoriteButton.tintColor = .systemYellow

        let constraints = [
            favoriteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func configure(todo: ToDoData) {
        titleLabel.text = todo.title
        if let date = todo.updatedAt {
            dateLabel.text = date.dateFormatterForTime()
        }

        let checkImageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        let checkImage = UIImage(systemName: todo.isDone ?? false ? "checkmark.square.fill" : "square", withConfiguration: checkImageConfig)

        checkBox.setImage(checkImage, for: .normal)

        checkBox.addAction(UIAction(handler: { [weak self] _ in
            if let id = todo.id {
                self?.delegate?.didTapCheckBox(id: id)
            }

        }), for: .touchUpInside)

        let favoriteImageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        let favoriteImage = UIImage(systemName: "star", withConfiguration: favoriteImageConfig)

        favoriteButton.setImage(favoriteImage, for: .normal)

        favoriteButton.addAction(UIAction(handler: { [weak self] _ in
            if let id = todo.id {
                self?.delegate?.didTapFavoriteBox(id: id)
            }
        }), for: .touchUpInside)
    }
}
