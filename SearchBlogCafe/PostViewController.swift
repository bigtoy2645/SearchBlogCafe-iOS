//
//  PostViewController.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/29.
//

import UIKit
import WebKit

class PostViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    static let segueID = "PostView"
    var post: PostModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let post = post, let link = URL(string: post.url) else {
            // TODO - 오류 페이지
            return
        }
        
        webView.navigationDelegate = self
        
        self.title = post.title.htmlEscaped()
        let request = URLRequest(url: link)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
        indicator.isHidden = true
    }
}
