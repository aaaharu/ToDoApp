//
//  AddVC.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import Foundation
import UIKit

class AddVC: UIViewController {
    
    var text: String = ""
    var finishBool: Bool = false
    var nowDate: String = ""
    var closureFirst: (() -> Void)?
    var closureSecond: (() -> Void)?
    
    
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var toDoTF: UITextField!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var boolSwitch: UISwitch!
    
    var addDataToSend: (text: String, bool: Bool, nowDate: String)? = nil
    
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
        
        guard !(toDoTF.text?.isEmpty ?? false), toDoTF.text?.count ?? 0 > 0 else { return }
        
        text = toDoTF.text!
        
        // 현재 날짜/시간 생성
            print(#fileID, #function, #line, "- text \(text)")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: Date())
        
            print(#fileID, #function, #line, "- dataString\(dateString)")
        
        nowDate = dateString
        
        let addDataToSend: [AnyHashable: Any] = ["text": self.text, "bool": self.finishBool, "nowDate": self.nowDate]
           
            print(#fileID, #function, #line, "- addDataToSend \(addDataToSend)")
        
        
        closureFirst = {
            NotificationCenter.default.post(name: Notification.Name("AddToDoList"), object: nil, userInfo: addDataToSend)
        }
        
        closureFirst?()
        
        closureSecond = { [weak self] in guard let self = self else { return }
                print(#fileID, #function, #line, "- 클로저가 실행되었따 ")
            self.callAddToDoListAPI(self.text, self.finishBool) {
            
        }
        }
        
        closureSecond?()
           
    
        self.performSegue(withIdentifier: "AddVCBackToVC", sender: self)
        
        //노티 등록
        
    
           
        
    }
    
    
    @IBAction fileprivate func boolSwitchClicked(_ sender: UISwitch) {
        
        finishBool.toggle()
            print(#fileID, #function, #line, "- finishBool: \(finishBool)")
        
            }
    
    fileprivate func callAddToDoListAPI(_ title: String, _ is_done: Bool, _ completion: @escaping () -> Void) {
        
        print(#fileID, #function, #line, "\(title), \(is_done) ")
        
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos-json"
        
        guard let url = URL(string: urlString) else { return }
        
   
        
        // JSON 데이터
        let priJsonData: [String: Any] = [
            "title" : "\(title)",
            // 완료 스위치를 누르면 false가 true로 바뀌는 토글 메서드 추가
            // 어떻게 넣지? 토글 기능으로
            "is_done" : is_done
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
                  httpResponse.statusCode == 200 else {

                let httpResponse = response as? HTTPURLResponse
                print(#fileID, #function, #line, "- 할일 목록 추가 실패(응답 코드: \(httpResponse?.statusCode)")
                return
            }
            
            print(#fileID, #function, #line, "- 할 일 목록 추가 성공(응답)")
        
            
            
        }
        
        task.resume()
        
        
        
        
    }
}


