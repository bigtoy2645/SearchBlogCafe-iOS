//
//  ViewController.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import UIKit
import Alamofire
import DropDown

enum FilterType: Int {
    case blog = 0x01
    case cafe = 0x02
    case all = 0xFF
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    
    var posts = [PostModel]()
    var filterType = FilterType.all
    var filterDropDown = DropDown()
    var searchDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 등록
        let nibName = UINib(nibName: SearchListTableViewCell.nibName, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: SearchListTableViewCell.cellID)
        tableView.rowHeight = UITableView.automaticDimension
        // 필터 & 정렬 뷰 추가
        tableView.tableHeaderView = filterView
        
        // 필터 버튼 설정
        filterButton.layer.cornerRadius = 8
        filterButton.layer.borderWidth = 0.5
        filterButton.layer.borderColor = UIColor.systemTeal.cgColor
        
        // 필터 설정
        filterDropDown.dataSource = ["All", "Blog", "Cafe"]
        filterDropDown.anchorView = filterButton
        filterDropDown.bottomOffset = CGPoint(x: 0, y:(filterDropDown.anchorView?.plainView.bounds.height)!)
        filterDropDown.cornerRadius = 8
        filterDropDown.backgroundColor = .white
        filterDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            filterButton.setTitle(item, for: .normal)
            if index == 0       { filterType = FilterType.all }
            else if index == 1  { filterType = FilterType.blog }
            else if index == 2  { filterType = FilterType.cafe }
            filterDropDown.clearSelection()
            searchButtonPressed(self)
        }
        
        // 이전 검색 목록 설정
        searchDropDown.dataSource = []
        searchDropDown.anchorView = searchField
        searchDropDown.bottomOffset = CGPoint(x: 0, y:(searchDropDown.anchorView?.plainView.bounds.height)!)
        searchDropDown.cornerRadius = 8
        searchDropDown.backgroundColor = .white
        searchDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            searchField.text = item
            searchDropDown.clearSelection()
            searchButtonPressed(self)
        }
    }
    
    /* 검색 버튼 클릭 */
    @IBAction func searchButtonPressed(_ sender: Any) {
        guard let currentSearchText = searchField.text else { return }
        
        // 검색
        search(for: currentSearchText, type: filterType)
        if currentSearchText.isEmpty { return }
        
        // 이전 검색 목록에 추가
        if let idx = searchDropDown.dataSource.firstIndex(of: currentSearchText) {
            searchDropDown.dataSource.remove(at: idx)
        }
        searchDropDown.dataSource.insert(currentSearchText, at: 0)
    }
    
    /* 필터 타입 변경 */
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        filterDropDown.show()
    }
    
    /* 정렬 타입 변경 */
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "가나다순", style: .default, handler: { action in
            self.posts.sort { $0.title > $1.title }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "최신순", style: .default, handler: { action in
            self.posts.sort { $0.date > $1.date }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /* Kakao Blog & Cafe 검색 */
    func search(for content: String, type: FilterType) {
        let headers: HTTPHeaders = [
            "Authorization": "KakaoAK \(KakaoAPI.key)"
        ]
        
        let parameters: [String: Any] = [
            "query": content,
            "size": KakaoAPI.size
        ]
        
        // 포스트 초기화
        posts.removeAll()
        
        // 검색 내용이 없으면 초기화
        if content.isEmpty {
            DispatchQueue.main.async { self.tableView.reloadData() }
            return
        }
        
        // Blog 검색
        if ((type.rawValue & FilterType.blog.rawValue) != 0) {
            AF.request(KakaoAPI.blog, method: .get,
                       parameters: parameters, headers: headers)
                .responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success:
                        guard let result = response.data else { return }
                        self.posts.append(contentsOf: self.parseJSON(blogData: result))
                        self.posts.sort { post1, post2 in
                            return post1.title > post2.title
                        }
                        self.tableView.reloadData()
                    case .failure(let error):
                        print(error)
                    }
                })
        }
        // Cafe 검색
        if ((type.rawValue & FilterType.cafe.rawValue) != 0) {
            AF.request(KakaoAPI.cafe, method: .get,
                       parameters: parameters, headers: headers)
                .responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success:
                        guard let result = response.data else { return }
                        self.posts.append(contentsOf: self.parseJSON(cafeData: result))
                        self.posts.sort { post1, post2 in
                            return post1.title > post2.title
                        }
                        self.tableView.reloadData()
                    case .failure(let error):
                        print(error)
                    }
                })
        }
    }
    
    /* Blog Data -> [PostModel] */
    private func parseJSON(blogData: Data) -> [PostModel] {
        let decoder = JSONDecoder()
        var blogPosts = [PostModel]()
        
        do {
            let data = try decoder.decode(BlogData.self, from: blogData)
            for post in data.documents {
                blogPosts.append(PostModel(type: FilterType.blog, name: post.blogname, contents: post.contents,
                                           date: DateUtil.parseDate(post.datetime), thumbnail: post.thumbnail, title: post.title, url: post.url))
            }
        } catch {
            print("Faile to get data from blog. \(error.localizedDescription)")
        }
        
        return blogPosts
    }
    
    /* Cafe Data -> [PostModel] */
    private func parseJSON(cafeData: Data) -> [PostModel] {
        let decoder = JSONDecoder()
        var cafePosts = [PostModel]()
        
        do {
            let data = try decoder.decode(CafeData.self, from: cafeData)
            for post in data.documents {
                cafePosts.append(PostModel(type: FilterType.cafe, name: post.cafename, contents: post.contents,
                                           date: DateUtil.parseDate(post.datetime), thumbnail: post.thumbnail, title: post.title, url: post.url))
            }
        } catch {
            print("Faile to get data from cafe. \(error.localizedDescription)")
        }
        
        return cafePosts
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    /* Cell 개수 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    /* Cell 그리기 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchListTableViewCell.cellID) as! SearchListTableViewCell
        
        // Cell 설정
        cell.name.text = posts[indexPath.row].name
        cell.date.text = DateUtil.formatDate(posts[indexPath.row].date, style: .short)
        if let thumbnail = posts[indexPath.row].thumbnailData {
            cell.thumbnail.image = UIImage(data: thumbnail)
        }
        
        // 타이틀 HTML 설정
        let titleWithFont = posts[indexPath.row].title.appendHtmlFont(size: 15)
        cell.titleView.attributedText = titleWithFont.htmlAttributedString()
        
        return cell
    }
    
    /* 검색 목록 클릭 시 디테일 화면으로 이동 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        performSegue(withIdentifier: DetailViewController.segueID, sender: post)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DetailViewController.segueID,
            let post = sender as? PostModel,
            let detailVC = segue.destination as? DetailViewController {
                detailVC.post = post
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    
    /* 입력 시 이전 검색 기록 표시 */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchDropDown.show()
    }
    
    /* 입력 중 이전 검색 기록 표시 */
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchDropDown.show()
    }
}
