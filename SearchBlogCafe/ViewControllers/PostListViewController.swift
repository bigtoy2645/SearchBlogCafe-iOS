//
//  ViewController.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import UIKit
import DropDown

protocol DetailDelegate {
    func didOpenURL(indexPath: IndexPath?)
}

class PostListViewController: UIViewController {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet var viewModel: PostListViewModel!
    let kakaoService = KakaoService()
    
    var filterDropDown = DropDown()
    var searchDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 등록
        let nibName = UINib(nibName: PostListTableViewCell.nibName, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: PostListTableViewCell.cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.setEmptyView(title: "검색 결과가 없습니다.")
        
        // 필터 & 정렬 뷰 추가
        tableView.tableHeaderView = filterView
        
        // 필터 버튼 설정
        filterButton.layer.cornerRadius = 8
        filterButton.layer.borderWidth = 0.5
        filterButton.layer.borderColor = UIColor.systemTeal.cgColor
        
        // Dropdown 설정
        configureFilter()
        configureOldSearch()
    }
    
    /* 검색 버튼 클릭 */
    @IBAction func searchButtonPressed(_ sender: Any) {
        guard let searchText = searchField.text else { return }
        
        // 데이터 요청
        viewModel.configure(keyword: searchText)
        getPosts(keyword: searchText)
        
        if searchText.isEmpty { return }
        
        // 이전 검색 목록에 추가
        if let idx = searchDropDown.dataSource.firstIndex(of: searchText) {
            searchDropDown.dataSource.remove(at: idx)
        }
        searchDropDown.dataSource.insert(searchText, at: 0)
        
        // 테이블 구분선 추가
        tableView.separatorStyle = .singleLine
    }
    
    /* 필터 타입 변경 */
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        filterDropDown.show()
    }
    
    /* 정렬 타입 변경 */
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "가나다순", style: .default,
                                      handler: { action in
                                        self.viewModel.sortPosts(Sort.title)
                                        DispatchQueue.main.async { self.tableView.reloadData() }
                                      }))
        alert.addAction(UIAlertAction(title: "최신순", style: .default,
                                      handler: { action in
                                        self.viewModel.sortPosts(Sort.date)
                                        DispatchQueue.main.async { self.tableView.reloadData() }
                                      }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /* 필터 설정 */
    func configureFilter() {
        filterDropDown.dataSource = ["All", "Blog", "Cafe"]
        filterDropDown.anchorView = filterButton
        filterDropDown.bottomOffset = CGPoint(x: 0, y:(filterDropDown.anchorView?.plainView.bounds.height)!)
        filterDropDown.cornerRadius = 8
        filterDropDown.backgroundColor = .white
        filterDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            filterButton.setTitle(item, for: .normal)
            if index == 0       { viewModel.filter = Filter.all }
            else if index == 1  { viewModel.filter = Filter.blog }
            else if index == 2  { viewModel.filter = Filter.cafe }
            filterDropDown.clearSelection()
            searchButtonPressed(self)
        }
    }
    
    /* 이전 검색 목록 설정 */
    func configureOldSearch() {
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
    
    /* Blog & Cafe 포스트 요청 */
    private func getPosts(keyword: String) {
        let nextPage = viewModel.nextPage()
        if (viewModel.filter.rawValue & Filter.blog.rawValue) != 0 {
            kakaoService.searchBlogPosts(for: keyword, page: nextPage) { blogPosts in
                guard let blogPosts = blogPosts else { return }
                self.viewModel.append(posts: blogPosts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        if (viewModel.filter.rawValue & Filter.cafe.rawValue) != 0 {
            kakaoService.searchCafePosts(for: keyword, page: nextPage) { cafePosts in
                guard let cafePosts = cafePosts else { return }
                self.viewModel.append(posts: cafePosts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension PostListViewController: UITableViewDataSource, UITableViewDelegate {
    
    /* Cell 개수 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    /* Cell 그리기 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostListTableViewCell.cellID) as! PostListTableViewCell
        
        // Cell 설정
        let post = viewModel.post(at: indexPath.row)
        cell.configure(post)
        
        return cell
    }
    
    /* 검색 목록 클릭 시 디테일 화면으로 이동 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: DetailViewController.storyboardID) as? DetailViewController else { return }
        detailVC.indexPath = indexPath
        detailVC.delegate = self
        detailVC.post = viewModel.post(at: indexPath.row)
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    /* 다음 목록 불러오기 */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if distanceFromBottom <= height {
            getPosts(keyword: viewModel.searchKeyword)
        }
    }
}

// MARK: - UITextFieldDelegate

extension PostListViewController: UITextFieldDelegate {
    
    /* 입력 중 이전 검색 기록 표시 */
    func textFieldDidChangeSelection(_ textField: UITextField) {
        searchDropDown.show()
    }
    
    /* 입력 후 이전 검색 기록 숨기기 */
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchDropDown.hide()
    }
}

// MARK: - DetailDelegate

extension PostListViewController: DetailDelegate {
    
    /* 포스트 읽음 처리 */
    func didOpenURL(indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        viewModel.setDim(at: indexPath.row)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
