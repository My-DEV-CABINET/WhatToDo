////
////  ToDoCell.swift
////  REST_TODO
////
////  Created by 준우의 MacBook 16 on 5/17/24.
////
//

/// Rx
import RxCocoa
import RxRelay
import RxSwift

/// Apple
import UIKit

final class ToDoCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var seenLabel: UILabel!
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var checkHandler: ((_ data: ToDoData) -> Void)?
    var favoriteHandler: ((_ id: Int) -> Void)?
    
    var data: ToDoData?

    // 셀 초기화시 호출
    override func awakeFromNib() {
        setup()
    }
    
    /// 셀이 안 보일 때
    override func prepareForReuse() {
        reset()
    }
    
    private func setup() {
        confirmCheckButton()
        confirmFavoriteButton()
    }
    
    private func reset() {
        data = nil
        checkHandler = nil
        favoriteHandler = nil
    }
    
    private func confirmCheckButton() {
        checkButton.addAction(UIAction(handler: { [weak self] _ in
            guard let data = self?.data else { return }
            self?.checkHandler?(data)
        }), for: .touchUpInside)
    }
    
    private func confirmFavoriteButton() {
        favoriteButton.addAction(UIAction(handler: { [weak self] _ in
            guard let id = self?.data?.id else { return }
            self?.favoriteHandler?(id)
        }), for: .touchUpInside)
    }
    
    func configure(data: ToDoData, isExistFavorite: Bool) {
        guard let id = data.id else { return }
        guard let isDone = data.isDone else { return }
        
        titleLabel.text = data.title
        dateLabel.text = data.createdAt?.dateFormatterForTime()
        
        SeenManager.shared.id = id
        seenLabel.isHidden = SeenManager.shared.existCheckInList
        
        let checkImage = isDone ? "checkmark.square.fill" : "square"
        checkButton.setImage(UIImage(systemName: checkImage), for: .normal)
        
        let favoriteImage = isExistFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: favoriteImage), for: .normal)
    }
}

// protocol ToDoCellDelegate {
//    func didTapCheckBox(todo: ToDoData)
//    func didTapFavoriteBox(id: Int)
// }
//
// final class ToDoCell: UITableViewCell {
//    static let identifier = Identifier.todoCell.rawValue
//
//    private var todo: ToDoData?
//    var delegate: ToDoCellDelegate?
//
//    var checkBox = UIButton(frame: .zero)
//    var favoriteButton = UIButton(frame: .zero)
//    var titleLabel = UILabel(frame: .zero)
//    var dateLabel = UILabel(frame: .zero)
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
// }
//
//// MARK: - Setting ToDoCell
//
// extension ToDoCell {
//    private func setupUI() {
//        addView()
//
//        configureCheckBox()
//        configureDateLabel()
//        configureTitleLabel()
//        configureFavoriteButton()
//    }
//
//    private func addView() {
//        [checkBox, titleLabel, dateLabel, favoriteButton].forEach { contentView.addSubview($0) }
//    }
//
//    private func configureCheckBox() {
//        checkBox.translatesAutoresizingMaskIntoConstraints = false
//
//        checkBox.tintColor = .black
//        checkBox.layer.cornerRadius = 10
//        checkBox.layer.masksToBounds = true
//
//        let constraints = [
//            checkBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            checkBox.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
//            checkBox.widthAnchor.constraint(equalToConstant: 30),
//            checkBox.heightAnchor.constraint(equalToConstant: 30)
//        ]
//
//        NSLayoutConstraint.activate(constraints)
//
//        checkBox.addAction(UIAction(handler: { [weak self] _ in
//            guard let self = self, let todo = self.todo else { return }
//            delegate?.didTapCheckBox(todo: todo)
//        }), for: .touchUpInside)
//    }
//
//    private func configureTitleLabel() {
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        titleLabel.textColor = .systemGray
//        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
//        titleLabel.numberOfLines = 2
//
//        let constraints = [
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            titleLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -10),
//            titleLabel.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 10),
//            titleLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -80)
//        ]
//
//        NSLayoutConstraint.activate(constraints)
//    }
//
//    private func configureDateLabel() {
//        dateLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        dateLabel.textColor = .systemGray2
//        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
//
//        let constraints = [
//            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
//            dateLabel.leftAnchor.constraint(equalTo: checkBox.rightAnchor, constant: 10),
//            dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 67),
//            dateLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 10)
//        ]
//
//        NSLayoutConstraint.activate(constraints)
//    }
//
//    private func configureFavoriteButton() {
//        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
//
//        favoriteButton.tintColor = .systemYellow
//
//        let constraints = [
//            favoriteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
//            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
//            favoriteButton.heightAnchor.constraint(equalToConstant: 30)
//        ]
//
//        NSLayoutConstraint.activate(constraints)
//
//        favoriteButton.addAction(UIAction(handler: { [weak self] _ in
//            guard let self = self, let todo = self.todo else { return }
//            if let id = todo.id {
//                delegate?.didTapFavoriteBox(id: id)
//            }
//        }), for: .touchUpInside)
//    }
//
//    func configure(todo: ToDoData, isExistFavorite: Bool) {
//        self.todo = todo
//        guard let isDone = todo.isDone else { return }
//
//        titleLabel.text = todo.title
//        if let date = todo.createdAt {
//            dateLabel.text = date.dateFormatterForTime()
//        }
//
//        let checkImageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
//        let checkImage = UIImage(systemName: isDone ? "checkmark.square.fill" : "square", withConfiguration: checkImageConfig)
//
//        checkBox.setImage(checkImage, for: .normal)
//
//        if isExistFavorite {
//            let favoriteImageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
//            let favoriteImage = UIImage(systemName: "star.fill", withConfiguration: favoriteImageConfig)
//            favoriteButton.setImage(favoriteImage, for: .normal)
//        } else {
//            let favoriteImageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
//            let favoriteImage = UIImage(systemName: "star", withConfiguration: favoriteImageConfig)
//            favoriteButton.setImage(favoriteImage, for: .normal)
//        }
//    }
// }
