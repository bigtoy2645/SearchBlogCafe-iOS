//
//  DetailViewController.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/29.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var titleView: UITextView!
    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var url: UILabel!
    
    static let segueID = "DetailView"
    
    var post: PostModel? {
        didSet {
            DispatchQueue.main.async {
                self.loadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 타이틀 최대 2줄
        titleView.textContainer.maximumNumberOfLines = 2
        titleView.textContainer.lineBreakMode = .byTruncatingTail
        
        loadData()
    }
    
    func loadData() {
        guard let post = self.post else { return }
        
        self.title = post.typeString
        name.text = post.name
        if let thumbnail = post.thumbnail {
            self.thumbnail.image = UIImage(data: thumbnail)
            self.thumbnail.layer.cornerRadius = 8
        }
        titleView.text = post.title
        date.text = ConvertUtil.formatDate(post.date)
        contents.text = post.contents
        url.text = post.url
    }
    
    /* URL로 이동 */
    @IBAction func linkButtonPressed(_ sender: UIButton) {
        guard let post = self.post else { return }
        performSegue(withIdentifier: PostViewController.segueID, sender: post)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PostViewController.segueID,
            let post = sender as? PostModel,
            let postVC = segue.destination as? PostViewController {
            postVC.post = post
        }
    }
}
