//
//  ViewController.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import UIKit
import DropDown
import RxSwift
import RxCocoa

protocol DetailDelegate {
    func didOpenURL(indexPath: IndexPath?)
}

class PostListViewController: UIViewController {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    
    @IBOutlet var viewModel: PostListViewModel!
    var disposeBag = DisposeBag()
    
    var filterDropDown = DropDown()
    var searchDropDown = DropDown()
    let pagingSpinner = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 등록
        let nibName = UINib(nibName: PostListTableViewCell.nibName, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: PostListTableViewCell.cellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.setEmptyView(title: "검색 결과가 없습니다.")
        
        // 필터, 정렬, 스피너 추가
        tableView.tableHeaderView = filterView
        pagingSpinner.hidesWhenStopped = true
        tableView.tableFooterView = pagingSpinner
        
        // 필터 버튼 설정
        filterButton.layer.cornerRadius = 8
        filterButton.layer.borderWidth = 0.5
        filterButton.layer.borderColor = UIColor.systemGray.cgColor
        
        // Dropdown 설정
        configureFilter()
        configureOldSearch()
        
        // 검색어 입력 Focusing
        searchField.becomeFirstResponder()
        
        // UI Binding
        setupBindings()
    }
    
    /* 검색 버튼 클릭 */
    @IBAction func searchButtonPressed(_ sender: Any) {
        view.endEditing(true)
        
        guard let searchText = searchField.text else { return }
        
        // 데이터 요청
        viewModel.searchKeyword.accept(searchText)
        if searchText.isEmpty { return }
        
        // 이전 검색 목록에 추가
        if let idx = searchDropDown.dataSource.firstIndex(of: searchText) {
            searchDropDown.dataSource.remove(at: idx)
        }
        searchDropDown.dataSource.insert(searchText, at: 0)
    }
    
    /* 필터 타입 변경 */
    @IBAction func filterButtonPressed(_ sender: UIButton) {
        filterDropDown.show()
    }
    
    /* 정렬 타입 변경 */
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "가나다순", style: .default,
                                      handler: { action in self.viewModel.sort.accept(.title) }))
        alert.addAction(UIAlertAction(title: "최신순", style: .default,
                                      handler: { action in self.viewModel.sort.accept(.date) }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /* 필터 설정 */
    func configureFilter() {
        filterDropDown.dataSource = viewModel.filterList
        filterDropDown.anchorView = filterButton
        filterDropDown.bottomOffset = CGPoint(x: 0, y:(filterDropDown.anchorView?.plainView.bounds.height)!)
        filterDropDown.cornerRadius = 8
        filterDropDown.backgroundColor = .white
        filterDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            viewModel.filter.accept(Filter(rawValue: index) ?? .all)
            filterDropDown.clearSelection()
            searchField.text = viewModel.searchKeyword.value
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
    
    // MARK: - UI Binding
    
    func setupBindings() {
        // Menu Cell
        viewModel.posts
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: PostListTableViewCell.cellID,
                                         cellType: PostListTableViewCell.self)) { index, item, cell in
                cell.bind(post: item)
            }
            .disposed(by: disposeBag)
        
        // 검색 완료 시
        viewModel.posts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.pagingSpinner.stopAnimating()
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.sort
            .map { $0 == .title ? UIImage(named: "sort-alphabet") : UIImage(named: "sort-time") }
            .bind(to: self.sortButton.rx.image())
            .disposed(by: disposeBag)
        
        viewModel.filter
            .map {
                self.viewModel.filterList[$0.rawValue]
            }
            .bind(to: self.filterButton.rx.title())
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension PostListViewController: UITableViewDelegate {
    
    /* 검색 목록 클릭 시 디테일 화면으로 이동 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: DetailViewController.storyboardID) as? DetailViewController else { return }
        detailVC.indexPath = indexPath
        detailVC.delegate = self
        detailVC.viewModel = PostViewModel(viewModel.posts.value[indexPath.row])
        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    /* 다음 목록 불러오기 */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        
        if distanceFromBottom <= height {
            if !viewModel.searchKeyword.value.isEmpty {
                pagingSpinner.startAnimating()
                viewModel.getPosts()
            }
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
    
    /* 엔터 입력 시 검색 */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonPressed(self)
        
        return true
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
