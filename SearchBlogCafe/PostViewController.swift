//
//  PostViewController.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/29.
//

import UIKit
import WebKit

class PostViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    static let segueID = "PostView"
    var post: PostModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let post = post, let link = URL(string: post.url) else {
            // TODO - 오류 페이지
            return
        }
        
        self.title = post.title
        let request = URLRequest(url: link)
        webView.load(request)
    }
}
