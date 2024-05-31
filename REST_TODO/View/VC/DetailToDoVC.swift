//
//  DetailToDoVC.swift
//  REST_TODO
//
//  Created by 준우의 MacBook 16 on 5/31/24.
//

import UIKit

final class DetailToDoVC: UIViewController {
    @IBOutlet weak var userActionLabel: UILabel!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var isConfirmSwitch: UISwitch!
    @IBOutlet weak var todoButton: UIButton!
    
    private var viewModel = DetailToDoViewModel()
    
   
}

//MARK: - View Life Cycle 관련 모음

extension DetailToDoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
