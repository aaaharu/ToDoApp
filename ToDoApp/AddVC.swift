//
//  AddVC.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import Foundation
import UIKit

class AddVC: UIViewController {
    
    @IBOutlet weak var finishBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    fileprivate func setupUI() {
        
        finishBtn.clipsToBounds = true
        finishBtn.layer.cornerRadius = 17
        
    }
    

    @IBAction func backBtnClicked(_ sender: UIBarButtonItem) {
    }
}
