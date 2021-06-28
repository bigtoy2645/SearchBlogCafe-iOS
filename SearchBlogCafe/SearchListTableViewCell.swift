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
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
