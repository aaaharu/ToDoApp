//
//  ViewController.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import SwipeCellKit
import UIKit

class ViewController: UIViewController{
    
    var boolValue: Bool = false
    
    var receiveData: (id: Int, text: String, boolValue: Bool)?
    
    var id: Int = 0
    
    // 섹션을 위해 데이터를 날짜 순으로 그룹화
    var groupingToDoList: [String: [Post]] = [:]
    var sectionDates: [String] = []
    
    
    // 검색 작업 아이템
    var searchDispatchWorkItem : DispatchWorkItem? = nil
    
    @IBOutlet weak var plusBtn: UIButton!
    
    @IBOutlet weak var hiddenFinishBtn: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myTableView: UITableView!
    
    var toDoList: [Post] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        myTableView.reloadData()
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenFinishBtn.titleLabel?.text = "완료 숨기기"
        myTableView.dataSource = self
        myTableView.delegate = self
        
        
        let nib = UINib(nibName: "ToDoCell", bundle: .main)
        myTableView.register(nib, forCellReuseIdentifier: "ToDoCell")
        setupUI()
        getToDoMethod()
        sectionHeight()
        
        
        // 노티 - 수신기 등록
        NotificationCenter.default.addObserver(self, selector: #selector(reCallGetTodo), name: Notification.Name("CustomNotification"), object: nil)
        
        
        
        
        // 검색
        searchBar.searchTextField.addTarget(self, action: #selector(searchBarInput(_:)), for: .editingChanged)
        
        // PutVC 받은 데이터
        if let text = receiveData?.text,
           let boolValue = receiveData?.boolValue,
           let id = receiveData?.id
        {
            print(#fileID, #function, #line, "- text \(text), boolValue \(boolValue), id\(id)")
            
            self.boolValue = boolValue
            
        }
        
    }
    
    
    
    @IBAction func backToVC(unwindSegue: UIStoryboardSegue) {
        print(#fileID, #function, #line, "- unwind")
        
        
        if let sourceVC = unwindSegue.source as? PutVC, let data = sourceVC.dataToSend as? (id: Int, text: String, boolValue: Bool) {
            receiveData = data
            
            print(#fileID, #function, #line, "- \(receiveData)")
        }
        
        
        callPutMethod(receiveData?.text ?? "")
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        print(#fileID, #function, #line, "- 아이디 보낸다 받아라")
        
        
        if segue.identifier == "NavtoPutVC" {
            
            let putVC = segue.destination as! PutVC
            
            putVC.id = self.id
            
        }
    }
    
    // 한글 String을 URL로 변환(한글로 query 검색 시 에러 뜸)
    func encodeKoreanToURL(_ KoreanString: String) -> String {
        
        
        let encodedString = KoreanString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return encodedString
    }
    
    @objc fileprivate func searchBarInput(_ searchTextField: UITextField) {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        let urlQuery: String? = encodeKoreanToURL(searchTextField.text ?? "")
        
        if let query = urlQuery {
            
            // 검색어가 입력되면 기존 작업 취소
            searchDispatchWorkItem?.cancel()
            
            let dispatchWorkItem = DispatchWorkItem(block: {
                // 백그라운드 - 사용자 입력 userInteractive
                DispatchQueue.global(qos: .userInteractive).async {
                    print(#fileID, #function, #line, "- 검색 API 호출하기 userInput: (searchTextField)")
                    
                    self.callSearchGET(query)
                }
            })
            
            // 기존작업을 나중에 취소하기 위해 메모리 주소 일치 시켜줌
            self.searchDispatchWorkItem = dispatchWorkItem
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: dispatchWorkItem)
            
            
            //        searchPhoto(searchInput)
        }
        
    }
    
    
    fileprivate func setupUI() {
        plusBtn.clipsToBounds = true
        plusBtn.layer.cornerRadius = 0.5 * plusBtn.bounds.size.width
        
    }
    
    @objc func reCallGetTodo() {
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos?page=1&order_by=desc&per_page=10"
        
        guard let url = URL(string: urlString) else { return }
        
        let urlReuqest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            
            
            guard let data = data else { return }
            //
            //            if let jsonString = String(data: data, encoding: .utf8) {
            //                    print(#fileID, #function, #line, "- \(jsonString)")
            //            }
            
            
            
            do {
                
                let todoResponse: ToDoResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                print(#fileID, #function, #line, "포스트\(todoResponse) ")
                
                self.toDoList = todoResponse.data
                
                // 섹션으로 정리한 배열 메서드 불러오기
                self.makeSection()
                
                
                DispatchQueue.main.async {
                    
                    self.myTableView.reloadData()
                }
                
                
            } catch {
                print(#fileID, #function, #line, "- \(error)")
            }
            
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print(#fileID, #function, #line, "- 할일 목록 가져오기 실패(응답)")
                return
            }
            
            print(#fileID, #function, #line, "- 할 일 목록 가져오기 성공(응답)")
            
        }.resume()
        
        
    }
    
    
    @objc fileprivate func callSearchGET(_ query: String) {
        print(#fileID, #function, #line, "-  주석 ")
        
        self.toDoList.removeAll()
        
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos/search?query=\(query)&order_by=desc&page=1&per_page=10"
        
        guard let url = URL(string: urlString) else { return     print(#fileID, #function, #line, "- Url 오류! ")}
        
        print(#fileID, #function, #line, "- \(url)")
        
        let urlReuqest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            print(#fileID, #function, #line, "- <# 주석 #>")
            
            guard let data = data else { return }
            //
            //            if let jsonString = String(data: data, encoding: .utf8) {
            //                    print(#fileID, #function, #line, "- \(jsonString)")
            //            }
            do {
                
                let todoResponse: ToDoResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                print(#fileID, #function, #line, "포스트\(todoResponse) ")
                
                
                self.toDoList = todoResponse.data
                
                print(#fileID, #function, #line, "- \(self.toDoList.count)")
                
                self.makeSection()
                
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
                
                
            } catch {
                print(#fileID, #function, #line, "- \(error)")
            }
            
            
            
            
            
            
        }.resume()
        
        
    }
    
    fileprivate func deleteMethod(_ deleteID: Int) {
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos/\(deleteID)"
        
        print(#fileID, #function, #line, "- \(urlString)")
        guard let url = URL(string: urlString) else { return }
        
        var urlReuqest = URLRequest(url: url)
        
        // httpMethod 기본 GET -> DELETE로 수정
        urlReuqest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            
            
            guard let data = data else { return }
            //
            //            if let jsonString = String(data: data, encoding: .utf8) {
            //                    print(#fileID, #function, #line, "- \(jsonString)")
            //            }
            do {
                
                let todoResponse: ToDoResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                print(#fileID, #function, #line, "포스트\(todoResponse) ")
                
                
                
            } catch {
                print(#fileID, #function, #line, "- \(error)")
            }
            
            
            
        }.resume()
        
    }
    
    
    fileprivate func getToDoMethod() {
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos?page=1&order_by=desc&per_page=10"
        
        guard let url = URL(string: urlString) else { return }
        
        let urlReuqest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            
            
            guard let data = data else { return }
            //
            //            if let jsonString = String(data: data, encoding: .utf8) {
            //                    print(#fileID, #function, #line, "- \(jsonString)")
            //            }
            do {
                
                let todoResponse: ToDoResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                print(#fileID, #function, #line, "포스트\(todoResponse) ")
                
                
                self.toDoList = todoResponse.data
                
                
                self.makeSection()
                
                
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
                
                
            } catch {
                print(#fileID, #function, #line, "- \(error)")
            }
            
            
            
            
            
            
        }.resume()
        
        
        
        
    }
    
    fileprivate func callPutMethod(_ putToDoTitle: String){
        print(#fileID, #function, #line, "-  \(id) ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos/\(id)"
        
        guard let url = URL(string: urlString) else { return }
        
        print(#fileID, #function, #line, "- url\(url)")
        
        
        // JSON 데이터
        let priJsonData: [String: Any] = [
            "title" : "\(putToDoTitle)",
            
            // 완료 스위치를 누르면 false가 true로 바뀌는 토글 메서드 추가
            // 어떻게 넣지? 토글 기능으로
            "is_done" : boolValue as Any
        ]
        
        // JSON 데이터로 직렬화하는 기능 - JSONSerialization
        let jsonData = try? JSONSerialization.data(withJSONObject: priJsonData)
        
        // HTTP 요청
        var urlReuqest = URLRequest(url: url)
        urlReuqest.httpMethod = "PUT"
        urlReuqest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlReuqest.httpBody = jsonData
        
        
        // 요청 보내기 - URLSession
        let task = URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            
            if let error = error {
                print(#fileID, #function, #line, "- 할일 목록 수정 실패 \(error.localizedDescription)")
                return
            }
            guard let data = data else { return     print(#fileID, #function, #line, "- 할 일 목록 수정 실패: 데이터가 없음")}
            //
            //            if let jsonString = String(data: data, encoding: .utf8) {
            //                    print(#fileID, #function, #line, "- \(jsonString)")
            //            }
            
            
            
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print(#fileID, #function, #line, "- 할일 목록 수정 실패(응답)")
                return
            }
            
            print(#fileID, #function, #line, "- 할 일 목록 수정 성공(응답)")
            do {
                
                
                self.getToDoMethod()
                
                
                //                let todoResponse: ToDoResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                //                print(#fileID, #function, #line, "포스트\(todoResponse) ")
                //
                //                // 데이터 업데이트
                //                self.toDoList = todoResponse.data
                //                self.makeSection()
                //
                //                // 테이블뷰 갱신
                //                DispatchQueue.main.async {
                //                    self.myTableView.reloadData()
                //                }
                
            } catch {
                print(#fileID, #function, #line, "- \(error)")
            }
        }
        
        task.resume()
        
        
        
        
    }
    
    
    fileprivate func makeSection(){
        
        //grouping : value 값, 뒤에는 key
        // 날짜 key, 그외 데이터 값
        groupingToDoList = Dictionary(grouping: toDoList) { post in
            guard let updated = post.upDated else { return "" }
            // subscript -> String (날짜)
            return String(updated.prefix(10))
        }
        
        // key순으로 정렬 -> 날짜(key) 섹션 추출 // 내림차순 정렬: sorted().reserved()
        sectionDates = groupingToDoList.keys.sorted().reversed()
        
        print(#fileID, #function, #line, "- toDoList \(groupingToDoList)")
        
        print(#fileID, #function, #line, "- \(sectionDates)")
    }
    
    
    @IBAction func hiddenFinishBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- \(String(describing: sender.titleLabel?.text))")
        
        // 완료 숨기기 <-> 전체보기
        guard let titleString = sender.titleLabel?.text else { return }
        
        print(#fileID, #function, #line, "- \(titleString)")
        
        if titleString == "완료 숨기기" {
            // isDone == true이면 숨기기
            // false만 데이터 배열에 다시 넣기, 섹션으로 묶기, 테이블뷰 다시 불러오기
            toDoList = toDoList.filter { !($0.isDone ?? false) }
            makeSection()
            myTableView.reloadData()
            sender.setTitle("전체보기", for: .normal)
        } else {
            // isDone == true 숨기기 취소
            // 데이터 배열 다시 로드(get호출), 섹션으로 묶기
            getToDoMethod()
            makeSection()
            sender.setTitle("완료 숨기기", for: .normal)
        }
        
        
        
        
        
        
        
    }
    
}











extension ViewController: UITableViewDataSource, SwipeTableViewCellDelegate, SendIdProtocol{
    
    
    
    
    // 오른쪽 셀 스와이프 - 삭제
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        
        
        if orientation == .right {
            
            let deleteAction = SwipeAction(style: .destructive, title: "삭제") { action, indexPath in
                
                if let deleteID = self.toDoList[indexPath.row].id {
                    
                    print(#fileID, #function, #line, "- \(self.toDoList.self)")
                    print(#fileID, #function, #line, "- \(deleteID)")
                    
                    
                    self.deleteMethod(deleteID)
                    
                    
                    
                    print(#fileID, #function, #line, "- \(self.toDoList.self)")
                    
                    
                    self.reCallGetTodo()
                    
                }
            }
            
            return [deleteAction]
            
        } else if orientation == .left  {
            
            
            
            let editAction = SwipeAction(style: .destructive, title: "수정") {
                action, indexPath in
                
                
                // checkBtn 클릭 -> 수정 api & PutVC 호출
                sendID()
                
                
                func sendID() {
                    
                    let sectionStirng = self.sectionDates[indexPath.section]
                    let postsInSection = self.groupingToDoList[sectionStirng]
                    let selectData = postsInSection?[indexPath.row]
                    
                    
                    
                    self.id = selectData?.id ?? 0
                    self.boolValue = ((selectData?.isDone) != nil)
                    
                    
                    
                }
                
                
                self.performSegue(withIdentifier: "NavtoPutVC", sender: self)
                
                
                
            }
            
            editAction.backgroundColor = .systemGreen
            
            return [editAction]
            
        }
        
        return nil
        
    }
    
    
    
    
    
    // 섹션 폰트
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let sectionLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        sectionLabel.font = UIFont(name: "Helvetica-Bold", size: 30)
        
        
        sectionLabel.textColor = .black
        sectionLabel.text = sectionDates[section]
        sectionLabel.sizeToFit()
        
        headerView.addSubview(sectionLabel)
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionString: String = sectionDates[section]
        
        // 섹션에 있는 날짜별로 행 반환
        return groupingToDoList[sectionString]?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoCell {
            print(#fileID, #function, #line, "- <# 주석 #>")
            
            //            if cell.label != nil {
            //                print(#fileID, #function, #line, "- 레이블이 연결되었습니다.")
            //            } else {
            //                print(#fileID, #function, #line, "- 레이블이 연결되지 않았습니다!")
            //            }
            
            //            let cellData: Post = toDoList[indexPath.row]
            
            cell.delegate = self
            
            
            // 날짜 가져오기
            let sectionString = sectionDates[indexPath.section]
            // 날짜별로 데이터 가져오기
            // posts 데이터 접근
            if let posts = groupingToDoList[sectionString] {
                print(#fileID, #function, #line, "- \(posts)")
                // post 특정 행에 접근
                let post = posts[indexPath.row]
                print(#fileID, #function, #line, "- \(post)")
                
                
                
                
                
                // 제목 표시
                if let title = post.title {
                    cell.label?.text = title
                } else {
                    cell.label?.text = "제목 없음"
                }
                
                // 셀 체크버튼 클릭
                let selectData = post
                if selectData.isDone == true {
                    cell.checkBtn.configuration?.baseForegroundColor = .black
                    // 취소선
                    let strikeThroughTask = NSMutableAttributedString(string: selectData.title!)
                    strikeThroughTask.addAttributes([
                        NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                        NSAttributedString.Key.strikethroughColor: UIColor.darkGray,
                        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0)
                    ], range: NSMakeRange(0, strikeThroughTask.length))
                    cell.label?.attributedText = strikeThroughTask
                } else {
                    cell.checkBtn.configuration?.baseForegroundColor = .lightGray
                }
                
                
                // 날짜 표시
                var time: String = ""
                if var upDate = post.upDated {
                    
                    
                    print(#fileID, #function, #line, "- \(upDate)")
                    
                    upDate.removeLast()
                    
                    print(#fileID, #function, #line, "- \(upDate)")
                    
                    
                    let customDateFormatter = DateFormatter()
                    customDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                    
                    
                    if let date = customDateFormatter.date(from: upDate) {
                        print(#fileID, #function, #line, "- \(date)")
                        time = DateFormatter.localizedString(from: date ?? Date(), dateStyle: .long, timeStyle: .short)
                    } else {
                        print(#fileID, #function, #line, "- 날짜 변환 실패")
                    }
                    
                    
                    cell.dateLabel?.text = time
                    
                } else {
                    cell.dateLabel?.text = "시간 없음"
                }
                
            }
            
            
            return cell
        }
        
        return UITableViewCell()
        
        
    }
    
    
    
    
    // 섹션 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDates.count
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 날짜 표시
        return sectionDates[section]
    }
    
    
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        // 셀에 인덱스패스 전달해주기
        // 셀에 접근
        guard let cell = tableView.cellForRow(at: indexPath) as? ToDoCell
        else { return }
        
        cell.indexPath = indexPath
        
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    fileprivate func sectionHeight() {
        self.myTableView.sectionHeaderHeight = UITableView.automaticDimension
        self.myTableView.estimatedSectionHeaderHeight = 50
    }
}



