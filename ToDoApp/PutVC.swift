//
//  PutVC.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/06/04.
//

import UIKit
import Foundation

class PutVC: UIViewController {
    
    var id: Int = 0
    var toDoTitle: String = ""
    var getBool: Bool?
    
    
    
    var dataToSend: (id: Int, text: String?, boolValue: Bool?)? = nil
    
    
    @IBOutlet var toDoTF: UITextField!
    @IBOutlet var boolSwitch: UISwitch!
    @IBOutlet var backBtn: UIBarButtonItem!
    @IBOutlet var finishBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(#fileID, #function, #line, "- id받았다 \(id)")
       
        makeUI()
        
    }
        
    fileprivate func makeUI() {
        toDoTF.text = toDoTitle
        if let getBool = getBool {
            boolSwitch.isOn = getBool
                print(#fileID, #function, #line, "- getBool \(getBool)")
        }
    }

    @IBAction func finishBtnClickd(_ sender: UIButton){
        guard let text = toDoTF.text, !text.isEmpty || finishBtn.isHighlighted else { return }
        
        print(#fileID, #function, #line, "- 피니시 버튼 테스트")
        
        
        
        // 보낼 데이터
        
//    dataToSend: (id: Int, text: String?, boolValue: Bool)?
        
        dataToSend = (id: id, text: toDoTF.text, boolValue: getBool)
        
            performSegue(withIdentifier: "BackToVC", sender: dataToSend)
            
        print(#fileID, #function, #line, "- 보낼 데이터\(String(describing: dataToSend))")
          
    }


    
    @IBAction fileprivate func boolSwitchClicked(_ sender: UISwitch) {
        
        getBool?.toggle()
        print(#fileID, #function, #line, "-  완료 상태 \(String(describing: getBool))")
        
    }
    
    
    
    
    
    fileprivate func callPutMethod(_ putToDoTitle: String){
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos/\(id)"
        
        guard let url = URL(string: urlString) else { return }
        
        
        
        
        // JSON 데이터
        let priJsonData: [String: Any] = [
            "title" : "\(putToDoTitle)",
            
            // 완료 스위치를 누르면 false가 true로 바뀌는 토글 메서드 추가
            // 어떻게 넣지? 토글 기능으로
            "is_done" : getBool as Any
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
                print(#fileID, #function, #line, "- 할일 목록 수정 실패 \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print(#fileID, #function, #line, "- 할일 목록 수정 실패(응답)")
                return
            }
            
            print(#fileID, #function, #line, "- 할 일 목록 수정 성공(응답)")
            
        }
        
        task.resume()
        
        
        
        
    }
    
    
    
    
}

