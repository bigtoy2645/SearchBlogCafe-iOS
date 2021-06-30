//
//  SearchListTableViewCell.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import UIKit

class SearchListTableViewCell: UITableViewCell {
    static let nibName = "SearchListTableViewCell"
    static let cellID = "SearchCell"
    
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
}
