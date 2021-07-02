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
    
    static let storyboardID = "DetailView"
    
    var delegate: DetailDelegate?
    var post: Post?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        // UITextView 여백 제거
        titleView.removeTextPadding()
        contents.removeTextPadding()
        
        // 타이틀 최대 2줄
        titleView.textContainer.maximumNumberOfLines = 2
        titleView.textContainer.lineBreakMode = .byTruncatingTail
    }
    
    /* 데이터 불러오기 */
    func loadData() {
        guard let post = self.post else { return }
        
        let postVM = PostViewModel(post)
        
        self.title = postVM.typeString
        name.text = post.name
        date.text = postVM.formatDate(style: .long)
        titleView.text = postVM.titleString
        contents.text = postVM.contentString
        url.text = post.url
        if let thumbnail = postVM.thumbnailData() {
            self.thumbnail.image = UIImage(data: thumbnail)
            self.thumbnail.layer.cornerRadius = 8
        }
    }
    
    /* URL로 이동 */
    @IBAction func linkButtonPressed(_ sender: UIButton) {
        guard let post = self.post else { return }
        performSegue(withIdentifier: PostViewController.segueID, sender: post)
        delegate?.didOpenURL(indexPath: indexPath)
    }
    
    /* PostViewController 설정 */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PostViewController.segueID,
            let post = sender as? Post,
            let postVC = segue.destination as? PostViewController {
            postVC.post = post
        }
    }
}
