//
//  ViewController.swift
//  ToDoApp
//
//  Created by 김은지 on 2023/05/30.
//

import SwipeCellKit
import UIKit

enum MyError: Error {
    case unknownError(err: Error?)
    case serverError(code: Int)
    case noData
    case notAllowedUrl
    case stringCountError(text: String)
    case nonSearchData
    //
    var errInfo : String {
        switch self {
        case .noData:                   return "데이터가 없습니다"
        case .notAllowedUrl:            return "허용되지 않는 URL 입니다"
        case .serverError(let code):    return "서버에러 입니다 : code : \(code)"
        case .stringCountError(let text):
            return "문자열의 길이는 최소 6자 이상입니다. 입력된 문자열의 길이: \(text.count)"
        case .nonSearchData:
            return "검색결과가 없습니다."
        case .unknownError(let err):
            let nsError = err as? NSError
            return "알 수 없는 에러 : \(nsError?.code ?? 999)"
        }
    }
}


class ViewController: UIViewController {
    
    var isSearchFunctionCalled = false
    
    var completionClosure: (() -> Void)?
    
    var putReceiveData: (id: Int, text: String, boolValue: Bool)?
    
    // MARK: - 데이터 담아서 putVC에 보내주기
    // 아이디, title, finish
    var id: Int = 0
    var toDotitle: String = ""
    var toDoFinish: Bool = false
    
    // 선택한 cell의 bool값을 담는 데이터
    var selectDataIsChanged: Bool =  false
    var testIsDone: Bool = false
    
    // 섹션을 위해 데이터를 날짜 순으로 그룹화
    var groupingToDoList: [String: [Post]] = [:]
    var sectionDates: [String] = []
    
    
    // 검색 작업 아이템
    var searchDispatchWorkItem : DispatchWorkItem? = nil
    
    @IBOutlet weak var trashStore: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var hiddenFinishBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myTableView: UITableView!
    
    var toDoList: [Post] = []
    var deleteToDoList: [Post] = []
    
    
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
        
        getToDoMethodWithError(completion: { [weak self] fetchedTodos, error in
            guard let self = self else { return }
            if let myErr : MyError = error {
//                self.handleErr(myErr)
                
                Utils.shared.showErrAlert(parentVC: self, myErr)
                return
            }
            
            guard let fetchedTodos = fetchedTodos else { return }
            
            self.toDoList = fetchedTodos
        
            self.makeSection()
        
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
            
        })
        
        sectionHeight()
        //         노티 - (발신:addVC) 할일 목록 추가시 reCallGetMethod 수신기 등록
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDataFromAddVC), name: Notification.Name("AddToDoList"), object: nil)
        
        // 노티 - (발신:ToDocell) 체크버튼 클릭시 완료 상태 변경 수신기 등록
        NotificationCenter.default.addObserver(self, selector: #selector(checkBtnClickedboolChanged), name: Notification.Name("toggleBoolBtn") , object: nil)
        
        // 검색
        searchBar.searchTextField.addTarget(self, action: #selector(searchBarInput(_:)), for: .editingChanged)
        
        
        
    }
    
    
    /// 에러처리
    /// - Parameter myErr: <#myErr description#>
    fileprivate func handleErr(_ myErr: MyError) {
        print(#fileID, #function, #line, "- myErr:\(myErr.errInfo)")
        
        
//        Utils.shared.showErrAlert(parentVC: <#T##UIViewController#>, <#T##myErr: MyError##MyError#>)
//        showErrAlert(myErr)
        
        switch myErr {
        case .unknownError(let err):
            print(#fileID, #function, #line, "- ")
        case .serverError(let code):
            print(#fileID, #function, #line, "- ")
        case .noData:
            print(#fileID, #function, #line, "- ")
        case .notAllowedUrl:
            print(#fileID, #function, #line, "- ")
        case .stringCountError(let text):
                print(#fileID, #function, #line, "- ")
        case .nonSearchData:
                print(#fileID, #function, #line, "- ")
        }
    }
    
//    private func showErrAlert(_ myErr: MyError){
//        let alert = UIAlertController(title: "에러", message: myErr.errInfo, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: NSLocalizedString("확인", comment: "Default action"), style: .default, handler: { _ in
//        NSLog("The \"OK\" alert occured.")
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
    
    @objc fileprivate func checkBtnClickedboolChanged(_ notification: Notification) {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if let data = notification.userInfo as? [String: Any] {
            
            let indexPath = data["indexPath"] as? IndexPath
            print(#fileID, #function, #line, "- 받아온 indexPath \(String(describing: indexPath))")
            
            guard let indexPath = indexPath else { return }
            
            // 날짜 가져오기
            let sectionString = sectionDates[indexPath.section]
            // 날짜별로 데이터 가져오기
            // posts 데이터 접근
            if let posts = groupingToDoList[sectionString] {
                print(#fileID, #function, #line, "- \(posts)")
                // post 특정 행에 접근
                var post = posts[indexPath.row]
                print(#fileID, #function, #line, "- \(String(describing: post.isDone))")
                
                post.id = self.id
                
                post.isDone = !post.isDone!
                // regrouping을 해줄 때 셀을 숨길 때 필요한 데이터
                toDoList[indexPath.row].isDone = post.isDone
                
                groupingToDoList[sectionString]?[indexPath.row].isDone = post.isDone
                
                
                let sendBoolValueArray = ["bool": post.isDone, "indexPath": indexPath] as [String : Any]
                
                print(#fileID, #function, #line, "여기에서 확인해보자 \(groupingToDoList) ")
                
                NotificationCenter.default.post(name: Notification.Name("VCsendBoolValue"), object: nil,userInfo: sendBoolValueArray as [AnyHashable : Any])
                
                
                print(#fileID, #function, #line, "- \(String(describing: post.isDone))")
                
                completionClosure = { [weak self] in
                    guard let self = self else { return }
                    print(#fileID, #function, #line, "- 클로저가 실행되었다.\(String(describing: post.title))")
                    
                    self.callPutMethod(post.title, post.isDone) {
                        
                        
                        
                    }
                    
                }
                completionClosure?()
                
                
            }
        }
        
        
        
    }
    
    
    // MARK: - 데이터
    // 휴지통
    
    
    
    // 완료 숨기기 - 데이터 섹션별로 정렬
    fileprivate func reMakeSection(_ grouping: [Post]){
        
        //grouping : value 값, 뒤에는 key
        // 날짜 key, 그외 데이터 값
        groupingToDoList = Dictionary(grouping: grouping) { post in
            guard let updated = post.upDated else { return "" }
            // subscript -> String (날짜)
            return String(updated.prefix(10))
        }
        
        // key순으로 정렬 -> 날짜(key) 섹션 추출 // 내림차순 정렬: sorted().reserved()
        sectionDates = groupingToDoList.keys.sorted().reversed()
        
        print(#fileID, #function, #line, "- toDoList \(groupingToDoList)")
        
        print(#fileID, #function, #line, "- \(sectionDates)")
    }
    
    
    // 데이터 섹션별로 정렬
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
    
    
    // MARK: - UI 관련
    
    fileprivate func setupUI() {
        plusBtn.clipsToBounds = true
        plusBtn.layer.cornerRadius = 0.5 * plusBtn.bounds.size.width
        
    }
    
    
    @IBAction func hiddenFinishBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- \(String(describing: sender.titleLabel?.text))")
        
        // 완료 숨기기 <-> 전체보기
        guard let titleString = sender.titleLabel?.text else { return }
        
        print(#fileID, #function, #line, "- \(titleString)")
        
        
        
        if titleString == "완료 숨기기" {
            // isDone == true이면 숨기기
            // false만 데이터 배열에 다시 넣기, 섹션으로 묶기, 테이블뷰 다시 불러오기
            
            //        let groupingPostMap = groupingToDoList.map{ $1 }.flatMap{ $0 }
            let reGrouping = toDoList.filter{ !($0.isDone ?? false) }
            print(#fileID, #function, #line, "- regrouping\(reGrouping)")
            reMakeSection(reGrouping)
            
            myTableView.reloadData()
            sender.setTitle("전체보기", for: .normal)
            
            
            
        } else {
            
            makeSection()
            myTableView.reloadData()
            
            // isDone == true 숨기기 취소
            // 데이터 배열 다시 로드(get호출), 섹션으로 묶기
            
            sender.setTitle("완료 숨기기", for: .normal)
        }
        
    }
    
    fileprivate func makeAddToDoList(_ title: String, _  isDone: Bool, _ nowDate: String) {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        guard var mostRecentItemID = toDoList.first?.id
                
        else { return }
        
        
        print(#fileID, #function, #line, "- 최신 아이디 \(mostRecentItemID)")
        
        var newPost = Post(upDated: nowDate, created: nowDate)
        newPost.title = title
        newPost.isDone = isDone
        newPost.id = mostRecentItemID + 1
        mostRecentItemID = 0
        
        toDoList.append(newPost)
        // 아이디 값 내림차순으로 정렬
        toDoList.sort(by: { $0.id ?? 0 > $1.id ?? 0 })
        
        makeSection()
        
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
        print(#fileID, #function, #line, "- 추가된 toDo목록 \(toDoList)")
    }
    // MARK: - unwindSegue
    
    
    @IBAction func trashBtnClicked(_ sender: UIButton) {
        print(#fileID, #function, #line, "- <# 주석 #>")
        self.performSegue(withIdentifier: "NavToTrashVC", sender: self)
    }
    
    
    @IBAction func backToVC(unwindSegue: UIStoryboardSegue) {
        print(#fileID, #function, #line, "- unwind")
        
        if let trashVC = unwindSegue.source as? TrashDataVC {
            self.toDoList.append(contentsOf: trashVC.getDeleteList)
            self.deleteToDoList.removeAll()
            
            makeSection()
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
            
            var deleteListCount = trashVC.getDeleteList.count
            
            // 복원한 데이터 POST로 다시 등록 해주기
            for i in 0..<deleteListCount {
    
                let title = trashVC.getDeleteList[i].title
                let isDone = trashVC.getDeleteList[i].isDone
                callPutMethod(title, isDone) {
                    self.getToDoMethod()
                }
            }
            
        }
        
        
        if let sourceVC = unwindSegue.source as? PutVC,
           let data = sourceVC.dataToSend as? (id: Int, text: String, boolValue: Bool) {
            
            if let putItemIndex = toDoList.firstIndex(where: { $0.id == data.id }) {
                toDoList[putItemIndex].title = data.text
                toDoList[putItemIndex].isDone = data.boolValue
                
            }
            
            makeSection()
            
            
            
            
            print(#fileID, #function, #line, "- \(String(describing: putReceiveData))")
        }
        
        
        
        
    }
    
    // MARK: -  PutVC로 데이터 보내기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        
        if segue.identifier == "NavToTrashVC" {
            
            if let trashVC = segue.destination as? TrashDataVC {
                
                print(#fileID, #function, #line, "- 쓰레기통 데이터 보내기")
                trashVC.getDeleteList = deleteToDoList
                
            }
            
            
        }
        
        
        if segue.identifier == "NavtoPutVC" {
            
            let putVC = segue.destination as! PutVC
            
            putVC.id = self.id
            putVC.toDoTitle = self.toDotitle
            putVC.getBool = self.toDoFinish
        }
    }
    
    
    // MARK: - API
    
    // 한글 String을 URL로 변환(한글로 query 검색 시 에러 뜸)
    func encodeKoreanToURL(_ KoreanString: String) -> String {
        
        
        let encodedString = KoreanString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return encodedString
    }
    
    @objc fileprivate func searchBarInput(_ searchTextField: UITextField) {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        var inputText: String?
        
        DispatchQueue.main.async {
            inputText = searchTextField.text
        }
        
        let urlQuery: String? = encodeKoreanToURL(searchTextField.text ?? "")
        
        // 함수가 한번 이상 호출되었다
        isSearchFunctionCalled = true
        
        
        if let query = urlQuery {
            
            // 검색어가 입력되면 기존 작업 취소
            searchDispatchWorkItem?.cancel()
            
            let dispatchWorkItem = DispatchWorkItem(block: {
                // 백그라운드 - 사용자 입력 userInteractive
                DispatchQueue.global(qos: .userInteractive).async {
                    print(#fileID, #function, #line, "- 검색 API 호출하기 userInput: (searchTextField)")
                    
                    if self.isSearchFunctionCalled && inputText?.isEmpty == true {
                        // 함수가 한번 이상 호출된 후에 수행할 동작
                        print(#fileID, #function, #line, "- 두개의 조건 만족")
                        self.getToDoMethod()
                    } else {
                        self.callSearchGET(query)
                    }
                }
            })
            
            // 기존작업을 나중에 취소하기 위해 메모리 주소 일치 시켜줌
            self.searchDispatchWorkItem = dispatchWorkItem
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: dispatchWorkItem)
            
            
            //        searchPhoto(searchInput)
        }
        
    }
    
    @objc func receiveDataFromAddVC(_ notification: Notification) {
        
        print(#fileID, #function, #line, "- 노티에서 데이터를 받아옵니다.")
        print(#fileID, #function, #line, "- \(String(describing: notification.userInfo))")
        
        if let userInfo = notification.userInfo,
           let text = userInfo["text"] as? String,
           let bool = userInfo["bool"] as? Bool,
           let nowDate =  userInfo["nowDate"] as? String
            
        {
            print(#fileID, #function, #line, "- \(text), \(bool), \(nowDate)")
            
            
            print(#fileID, #function, #line, "- makeAddToDoList가 이제 곧 호출됩니다.")
            makeAddToDoList(text, bool, nowDate)
        }
    }
    
    @objc func reCallGetTodo() {
        print(#fileID, #function, #line, "- get메서드가 호출되었다.")
        
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
                print(#fileID, #function, #line, "- 데이터 테스트 \(self.toDoList)")
                
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
        
        guard let url = URL(string: urlString) else {
            let error = MyError.notAllowedUrl
            Utils.shared.showErrAlert(parentVC: self, error)
            return
        }
        
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
                let nonSearchError = MyError.nonSearchData
                Utils.shared.showErrAlert(parentVC: self, nonSearchError)
                return
            }
            
            
        }.resume()
        
        
    }
    
    fileprivate func deleteMethod(_ deleteID: Int, completion: @escaping () -> Void, errorCompletion: @escaping (MyError?) -> Void) {
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos/\(deleteID)"
        
        print(#fileID, #function, #line, "- \(urlString)")
        guard let url = URL(string: urlString) else { return }
        
        var urlReuqest = URLRequest(url: url)
        
        // httpMethod 기본 GET -> DELETE로 수정
        urlReuqest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            
            guard let data = data else { return }
            do {
                let todoResponse: ItemResponse<Post> = try JSONDecoder().decode(ItemResponse<Post>.self, from: data)
                print(#fileID, #function, #line, "포스트\(todoResponse) ")
                completion()
            } catch {
                print(#fileID, #function, #line, "- \(error.localizedDescription)")
                errorCompletion(MyError.noData)
            }
            
            let errorResponse = response as? HTTPURLResponse
               
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else { print(errorResponse?.statusCode ?? 404)
                let error = MyError.noData
                Utils.shared.showErrAlert(parentVC: self, error)
                return
                
             
                
            }
            
        }.resume()
        
    }
    
//    self.toDoList = todoResponse.data
//
//    self.makeSection()
//
//    DispatchQueue.main.async {
//        self.myTableView.reloadData()
//    }
    
    // PostList 가져올 것
    fileprivate func getToDoMethodWithError(completion: @escaping ([Post]?, MyError?) -> Void) {
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos?page=1&order_by=desc&per_page=10"
        
        guard let url = URL(string: urlString) else {
            completion(nil, MyError.notAllowedUrl)
            return
        }
        
        let urlReuqest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            
            if let error : Error = error {
                completion(nil, MyError.unknownError(err: error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                if !(200...299).contains(code) {
                    print(#fileID, #function, #line, "- 코드에러 입니다")
                    completion(nil, MyError.serverError(code: code))
                    return
                }
            }
            
            guard let data = data else { return }
            do {
                let todoResponse: ToDoResponse = try JSONDecoder().decode(ToDoResponse.self, from: data)
                print(#fileID, #function, #line, "포스트\(todoResponse) ")
                
                let fetchedTodos = todoResponse.data
                
                completion(nil, MyError.noData)
                
//                if fetchedTodos.count > 1 {
//                    completion(todoResponse.data, nil)
//                } else {
//                    completion(nil, MyError.noData)
//                }
                
            } catch {
                print(#fileID, #function, #line, "- \(error)")
                completion(nil, MyError.unknownError(err: error))
            }
            
        }.resume()
    }
    
    fileprivate func getToDoMethod() {
        print(#fileID, #function, #line, "-  주석 ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos?page=1&order_by=desc&per_page=10"
        
        guard let url = URL(string: urlString) else { return }
        
        let urlReuqest = URLRequest(url: url)
        URLSession.shared.dataTask(with: urlReuqest) { data, response, error in
            
            if error != nil {
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                if !(200...299).contains(code) {
                    print(#fileID, #function, #line, "- 코드에러 입니다")
                    return
                }
            }
            
            guard let data = data else { return }
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
    
    fileprivate func callPutMethod(_ putToDoTitle: String?, _ is_done: Bool?, completion: @escaping () -> Void?){
        print(#fileID, #function, #line, "-  \(id) ")
        
        let urlString: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/v1/todos/\(id)"
        
        print(#fileID, #function, #line, "- urlString\(urlString)")
        
        guard let url = URL(string: urlString) else { return }
        
        print(#fileID, #function, #line, "- url\(url)")
        
        var title: String = ""
        var unWrapedIsDone: Bool = true
        
        // 타이틀 옵셔널 벗기기
        if putToDoTitle != nil || !(putToDoTitle?.isEmpty ?? true) {
            title = putToDoTitle ?? ""
        }
        
        // 불값 옵셔널 벗기기
        if is_done != nil {
            unWrapedIsDone = is_done ?? true
        }
        print(#fileID, #function, #line, "- \(String(describing: is_done))")
        print(#fileID, #function, #line, "- \(unWrapedIsDone)")
        
        // JSON 데이터
        let preJsonData: [String: Any] = [
            
            "title" : "\(String(describing: title))",
            
            // 완료 스위치를 누르면 false가 true로 바뀌는 토글 메서드 추가
            // 어떻게 넣지? 토글 기능으로
            "is_done" : unWrapedIsDone
            
        ]
        
        
        
        // JSON 데이터로 직렬화하는 기능 - JSONSerialization
        let jsonData = try? JSONSerialization.data(withJSONObject: preJsonData)
        
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
            guard data != nil else { return     print(#fileID, #function, #line, "- 할 일 목록 수정 실패: 데이터가 없음")}
            //
            //            if let jsonString = String(data: data, encoding: .utf8) {
            //                    print(#fileID, #function, #line, "- \(jsonString)")
            //            }
            
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                let httpResponse = response as? HTTPURLResponse
                
                print(#fileID, #function, #line, "- 할일 목록 수정 실패(응답코드: \(httpResponse?.statusCode)")
                return
            }
            
            print(#fileID, #function, #line, "- 할 일 목록 수정 성공(응답)")
            do {
                
                
                completion()
                
                
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
    
    
    
}


// MARK: - TableView 그리기

extension ViewController: UITableViewDataSource, SwipeTableViewCellDelegate, SendIdProtocol{
    
    
    
    // 오른쪽 셀 스와이프 - 삭제
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        
        if orientation == .right {
            
            let deleteAction = SwipeAction(style: .destructive, title: "삭제") { action, indexPath in
                
                // 휴지통에 넣기
                self.deleteToDoList.append(self.findItem(indexPath: indexPath)!)
                
                print(#fileID, #function, #line, "- deleteToDoList \(self.deleteToDoList)")
                
                if let deleteID = self.findItem(indexPath: indexPath)?.id {
                    
                    
                    
                    self.deleteMethod(deleteID, completion: { [weak self] in
                        
                        guard let self = self else { return }
                        
                        self.removeItem(indexPath: indexPath)
                        
                        DispatchQueue.main.async {
                            
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            //                            let sectionString = self.sectionDates[indexPath.section]
                            //                            if self.groupingToDoList[sectionString]?.count ?? 0 < 1 {
                            //
                            //                                let indexSet = IndexSet(integer: indexPath.section)
                            //                                tableView.deleteSections(indexSet, with: .fade)
                            //                            }
                        }
                    }, errorCompletion: {_ in }
                                      )}
                
                //                if let deleteID = self.toDoList[indexPath.row].id {
                //
                //                    print(#fileID, #function, #line, "- \(self.toDoList.self)")
                //                    print(#fileID, #function, #line, "- \(deleteID)")
                //
                //
                //                    self.deleteMethod(deleteID, completion: { [weak self] in
                //
                //                        guard let self = self else { return }
                //
                //                        let sectionString = self.sectionDates[indexPath.section]
                //
                //                        self.groupingToDoList[sectionString]?.remove(at: indexPath.row)
                //                        DispatchQueue.main.async {
                //                            tableView.deleteRows(at: [indexPath], with: .fade)
                //                        }
                //                    })
                //
                //                    print(#fileID, #function, #line, "- \(self.toDoList.count)")
                ////                    self.reCallGetTodo()
                //
                //                }
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
                    
                    // 아이디 값 넣어주기
                    self.id = selectData?.id ?? 0
                    self.testIsDone = ((selectData?.isDone) != nil)
                    self.toDotitle = selectData?.title ?? ""
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
        //        let sectionString: String = sectionDates[section]
        //
        //        // 섹션에 있는 날짜별로 행 반환
        //        return groupingToDoList[sectionString]?.count ?? 0
        return getRows(section: section).count
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return makeTodoCell(tableView: tableView, indexPath: indexPath)
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
        cell.selectionStyle = .none
        
        
        sendID()
        
        func sendID() {
            
            let sectionStirng = self.sectionDates[indexPath.section]
            let postsInSection = self.groupingToDoList[sectionStirng]
            let selectData = postsInSection?[indexPath.row]
            
            
            // 아이디 값 넣어주기
            self.id = selectData?.id ?? 0
            self.testIsDone = ((selectData?.isDone) != nil)
            self.toDotitle = selectData?.title ?? ""
            self.toDoFinish = ((selectData?.isDone) != nil)
            
            
        }
        
    }
    
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let sectionString = sectionDates[section]
        
        // 섹션에 있는 날짜별로 행 반환
        let rowsCount = groupingToDoList[sectionString]?.count ?? 0
        
        if rowsCount < 1 {
            return 0.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    fileprivate func sectionHeight() {
        self.myTableView.sectionHeaderHeight = UITableView.automaticDimension
        self.myTableView.estimatedSectionHeaderHeight = 50
    }
}

//MARK: - Helpers

extension ViewController {
    
    
    
    private func findIndexPath(dataItem: Post) -> IndexPath {
        
        let sectionIndex = sectionDates.firstIndex(of: dataItem.upDated ?? "") ?? 0
        
        let sectionString: String = sectionDates[sectionIndex]
        
        // 섹션에 있는 날짜별로 행 반환
        let rowItems = groupingToDoList[sectionString] ?? []
        
        let rowIndex = rowItems.firstIndex(where: { $0.id ?? 0 == dataItem.id ?? 0 }) ?? 0
        
        return IndexPath(row: rowIndex, section: sectionIndex)
    }
    
    private func findItem(indexPath: IndexPath) -> Post? {
        
        let sectionString: String = sectionDates[indexPath.section]
        
        // 섹션에 있는 날짜별로 행 반환
        return groupingToDoList[sectionString]?[indexPath.row]
    }
    
    private func removeItem(indexPath: IndexPath) {
        
        let sectionString = sectionDates[indexPath.section]
        
        // 섹션에 있는 날짜별로 행 반환
        groupingToDoList[sectionString]?.remove(at: indexPath.row)
    }
    
    private func removeData(dataItem: Post) {
        
        let sectionIndex = sectionDates.firstIndex(of: dataItem.upDated ?? "") ?? 0
        
        let sectionString: String = sectionDates[sectionIndex]
        
        if groupingToDoList[sectionString]?.count ?? 0 < 1 {
            groupingToDoList.removeValue(forKey: sectionString)
            return
        }
        
        // 섹션에 있는 날짜별로 행 반환
        var rowItems = groupingToDoList[sectionString] ?? []
        
        let rowIndex = rowItems.firstIndex(where: { $0.id ?? 0 == dataItem.id ?? 0 }) ?? 0
        
        groupingToDoList[sectionString]?.remove(at: rowIndex)
        
        
        
    }
}

//MARK: - Helpers
extension ViewController {
    
    
    fileprivate func getRows(section: Int) -> [Post] {
        let sectionString: String = sectionDates[section]
        
        // 섹션에 있는 날짜별로 행 반환
        return groupingToDoList[sectionString] ?? []
    }
    
    
    fileprivate func makeTodoCell(tableView: UITableView,
                                  indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoCell else {
            return UITableViewCell()
        }
        
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        //            if cell.label != nil {
        //                print(#fileID, #function, #line, "- 레이블이 연결되었습니다.")
        //            } else {
        //                print(#fileID, #function, #line, "- 레이블이 연결되지 않았습니다!")
        //            }
        
        //            let cellData: Post = toDoList[indexPath.row]
        
        cell.delegate = self
        //            cell.clickedCheckDelegate = self
        
        // 날짜 가져오기
        let sectionString = sectionDates[indexPath.section]
        // 날짜별로 데이터 가져오기
        
        // posts 데이터 접근
        if let posts = groupingToDoList[sectionString] {
            print(#fileID, #function, #line, "- \(posts)")
            // post 특정 행에 접근
            let post = posts[indexPath.row]
            print(#fileID, #function, #line, "- \(post)")
            
            selectDataIsChanged = post.isDone ?? false
            
            cell.indexPath = indexPath
            cell.testIsDone = testIsDone
            
            cell.idLabel.text = "ID: \(post.id ?? 0)"
            
            // 제목 표시
            if let title = post.title {
                cell.label?.text = title
            } else {
                cell.label?.text = "제목 없음"
            }
            
            // 취소선
            if  post.isDone!{
                cell.checkBtn.configuration?.baseForegroundColor = .black
                // 취소선이 셀이 재사용되면서 여전히 남아버림. -> prepareForReuse에서 셀의 속성 초기화 작업할것
                let strikeThroughTask = NSMutableAttributedString(string: cell.label.text ?? "")
                strikeThroughTask.addAttributes([
                    NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.strikethroughColor: UIColor.darkGray,
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17.0)
                ], range: NSMakeRange(0, strikeThroughTask.length))
                cell.label?.attributedText = strikeThroughTask
                
            } else {
                
                cell.checkBtn.configuration?.baseForegroundColor = .lightGray
                let originalString = cell.label.text ?? ""
                let attributedString = NSMutableAttributedString(string: originalString)
                attributedString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributedString.length))
                attributedString.removeAttribute(NSAttributedString.Key.strikethroughColor, range: NSMakeRange(0, attributedString.length))
                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17.0), range: NSMakeRange(0, attributedString.length))
                cell.label?.attributedText = attributedString
                
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
}

