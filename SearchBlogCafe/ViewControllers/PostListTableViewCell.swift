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
        self.type.text = post.typeString
        self.name.text = post.name
        self.titleView.text = post.title
        self.date.text = DateUtil.formatDate(post.date, style: .short)
        if let thumbnail = post.thumbnailData {
            self.thumbnail.image = UIImage(data: thumbnail)
        }
        
        // 읽음 처리
        self.contentView.alpha = post.isRead ? 0.3 : 1.0
    }
}
