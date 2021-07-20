//
//  UITableView+Empty.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/30.
//

import UIKit

extension UITableView {
    /* 검색 결과 없음 화면 */
    func setEmptyView(title: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.systemGray
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        emptyView.addSubview(titleLabel)
        
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.text = title
        
        self.backgroundView = emptyView
    }
}
