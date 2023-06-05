//
//  AddVC.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import Foundation
import UIKit

class AddVC: UIViewController {
    
    var finishBool: Bool = false
  
   
    
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var toDoTF: UITextField!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var boolSwitch: UISwitch!
    
    
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
    
    
    @IBAction fileprivate func boolSwitchClicked(_ sender: UISwitch) {
        
        finishBool.toggle()
            print(#fileID, #function, #line, "- finishBool: \(finishBool)")
        
            }
    
    fileprivate func callPost(_ addToDoTitle: String){
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos"
        
        guard let url = URL(string: urlString) else { return }
        
        
        let now = Date()
        let dateFormatter = DateFormatter()
        let dateString = dateFormatter.string(from: now)
        
        // JSON 데이터
        let priJsonData: [String: Any] = [
            "title" : "\(addToDoTitle)",
            // 완료 스위치를 누르면 false가 true로 바뀌는 토글 메서드 추가
            // 어떻게 넣지? 토글 기능으로
            "is_done" : finishBool,
            "updated_at" : dateString
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


