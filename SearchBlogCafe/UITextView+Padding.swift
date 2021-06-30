//
//  UITextView+Padding.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/30.
//

import UIKit

extension UITextView {
    
    /* TextView 여백 제거 */
    func removeTextPadding() {
        self.textContainerInset = UIEdgeInsets.zero
        self.textContainer.lineFragmentPadding = 0
    }
}
