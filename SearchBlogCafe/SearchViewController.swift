//
//  ViewController.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var cafeContents = [Cafe]()
    var blogContents = [Blog]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 등록
        let nibName = UINib(nibName: SearchListTableViewCell.nibName, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: SearchListTableViewCell.cellID)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    /* 검색 버튼 클릭 */
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        guard let currentSearchText = searchBar.text else { return }
        
        searchKakaoAPI(content: currentSearchText)
    }
    
    /* Kakao Blog & Cafe 검색 */
    func searchKakaoAPI(content: String) {
        let headers: HTTPHeaders = [
            "Authorization": "KakaoAK \(KakaoAPI.key)"
        ]
        
        let parameters: [String: Any] = [
            "query": content,
            "size": KakaoAPI.size
        ]
        
        AF.request(KakaoAPI.cafe, method: .get,
                   parameters: parameters, headers: headers)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    guard let result = response.data else { return }
                    do {
                        let decoder = JSONDecoder()
                        let cafeData = try decoder.decode(CafeData.self, from: result)
                        self.cafeContents = cafeData.documents
                    } catch {
                        print("Faile to get data from cafe. \(error.localizedDescription)")
                    }
                    
                case .failure(let error):
                    print(error)
                }
            })
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    /* Section = 필터 + 리스트 */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /* Cell 개수 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return cafeContents.count + blogContents.count
    }
    
    /* Cell 그리기 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // TODO - 타입, 필터
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchListTableViewCell.cellID) as! SearchListTableViewCell
        
        // TODO - Cell 설정
        
        return cell
    }
    
    /* 검색 목록 클릭 시 디테일 화면으로 이동 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO - 디테일 화면으로 이동
    }
}
