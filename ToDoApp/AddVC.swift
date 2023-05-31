//
//  AddVC.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import Foundation
import UIKit

class AddVC: UIViewController {
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var toDoTF: UITextField!
    @IBOutlet weak var finishBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        
        
    }
    
    @IBAction func backBtnClicked(_ sender: UIBarButtonItem) {
        
      
        
    }
    
    
    
    fileprivate func setupUI() {
        
        finishBtn.clipsToBounds = true
        finishBtn.layer.cornerRadius = 17
        
    }
    
    @IBAction func finishBtnCLicked(_ sender: UIButton) {
        
        guard let text = toDoTF.text, !text.isEmpty else { return }
        
        guard text.count > 0 else { return }
        
        callPost(text)
        
        //노티 등록
        
        NotificationCenter.default.post(name: Notification.Name("CustomNotification"), object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.popViewController(animated: true)
           }
           
        
    }
    
    
    
    fileprivate func callPost(_ AddToDo: String){
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos"
        
        guard let url = URL(string: urlString) else { return }
        
        
        
        // JSON 데이터
        let priJsonData: [String: Any] = [
            "title" : "\(AddToDo)",
            "is_done" : false
        ]
        
        // JSON 데이터로 직렬화하는 기능 - JSONSerialization
        let jsonData = try? JSONSerialization.data(withJSONObject: priJsonData)
        
        // HTTP 요청
        var urlReuqest = URLRequest(url: url)
        urlReuqest.httpMethod = "POST"
        urlReuqest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReuqest.httpBody = jsonData
        
        
        // 요청 보내기 - URLSession
        let task = URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            
            if let error = error {
                print(#fileID, #function, #line, "- 할일 목록 추가 실패 \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {     print(#fileID, #function, #line, "- 할일 목록 추가 실패(응답)")
                return
            }
            
            print(#fileID, #function, #line, "- 할 일 목록 추가 성공(응답)")
        
            
            
        }
        
        task.resume()
        
        
        
        
    }
}


