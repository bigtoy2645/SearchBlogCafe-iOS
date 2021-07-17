//
//  PostViewController.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/29.
//

import UIKit
import WebKit
import RxSwift

class PostViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    static let segueID = "PostView"
    var viewModel = PostViewModel(Post.empty)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.post.map { $0.title }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.title = $0
            })
            .disposed(by: disposeBag)
        
        viewModel.post.map { $0.url }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let link = URL(string: $0) else { return }
                let request = URLRequest(url: link)
                self?.webView.load(request)
            })
            .disposed(by: disposeBag)
    }
}
