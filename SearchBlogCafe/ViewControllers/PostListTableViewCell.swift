//
//  SearchListTableViewCell.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import UIKit

class PostListTableViewCell: UITableViewCell {
    
    static let nibName = "PostListTableViewCell"
    static let cellID = "PostCell"
    
    @IBOutlet weak var type: UILabel!  // Blog/Cafe
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var titleView: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 이미지 둥글게
        self.thumbnail.layer.cornerRadius = 8
        
        // UITextView 여백 제거
        titleView.removeTextPadding()
        
        // 타이틀 최대 2줄
        titleView.textContainer.maximumNumberOfLines = 2
        titleView.textContainer.lineBreakMode = .byTruncatingTail
    }
    
    func configure(_ post: Post) {
        let postVM = PostViewModel(post)
        
        self.type.text = postVM.typeString
        self.name.text = post.name
        self.titleView.text = postVM.titleString
        self.date.text = postVM.formatDate(style: .short)
        if let thumbnail = postVM.thumbnailData() {
            self.thumbnail.image = UIImage(data: thumbnail)
        }
        
        // 읽음 처리
        self.contentView.alpha = CGFloat(postVM.alpha)
    }
}
