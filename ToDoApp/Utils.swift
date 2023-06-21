//
//  Utils.swift
//  ToDoApp
//
//  Created by Jeff Jeong on 2023/06/15.
//

import Foundation
import UIKit

class Utils {
    
    static let shared = Utils()
    
    
    func showErrAlert(parentVC: UIViewController, _ myErr: MyError){
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "에러", message: myErr.errInfo, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("확인", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            parentVC.present(alert, animated: true, completion: nil)
        }
            
    }
    
}
