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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    
    var posts = [PostModel]()
    var filterType = FilterType.all
    var dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 등록
        let nibName = UINib(nibName: SearchListTableViewCell.nibName, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: SearchListTableViewCell.cellID)
        tableView.rowHeight = UITableView.automaticDimension
        // 필터 & 정렬 뷰 추가
        tableView.tableHeaderView = filterView
        
        // 필터 버튼 둥글게
        filterButton.layer.cornerRadius = 8
        
        // 필터 설정
        dropDown.dataSource = ["All", "Blog", "Cafe"]
        dropDown.anchorView = filterButton
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.cornerRadius = 8
        dropDown.backgroundColor = filterButton.backgroundColor
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            filterButton.setTitle(item, for: .normal)
            if index == 0       { filterType = FilterType.all }
            else if index == 1  { filterType = FilterType.blog }
            else if index == 2  { filterType = FilterType.cafe }
            self.dropDown.clearSelection()
            if let currentSearchText = searchBar.text {
                self.search(for: currentSearchText, type: filterType)
            }
        }
    }
    
    /* 검색 버튼 클릭 */
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        guard let currentSearchText = searchBar.text else { return }
        
        search(for: currentSearchText, type: filterType)
    }
    
    /* 필터 타입 변경 */
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        dropDown.show()
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
                        // TODO - Cafe, Blog 검색 후 한번에 reload
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
                                           date: ConvertUtil.parseDate(post.datetime), thumbnail: ConvertUtil.getDataFrom(url: post.thumbnail), title: post.title, url: post.url))
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
                                           date: ConvertUtil.parseDate(post.datetime), thumbnail: ConvertUtil.getDataFrom(url: post.thumbnail), title: post.title, url: post.url))
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
        cell.date.text = ConvertUtil.formatDate(posts[indexPath.row].date)
        if let thumbnail = posts[indexPath.row].thumbnail {
            cell.thumbnail.image = UIImage(data: thumbnail)
        }
        cell.type.text = posts[indexPath.row].typeString
//        if let data = posts[indexPath.row].title.data(using: .utf16) {
//            cell.titleView.attributedText = try? NSAttributedString(
//                data: data,
//                options: [.documentType: NSAttributedString.DocumentType.html],
//                documentAttributes: nil)
//        }
        cell.titleView.text = posts[indexPath.row].title
        
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

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    /* 기존 검색 목록 표시 */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // TODO - 키워드 선택 시 검색
        self.searchBar.text = searchBar.text
        if let currentSearchText = self.searchBar.text {
            search(for: currentSearchText, type: filterType)
        }
    }
}
