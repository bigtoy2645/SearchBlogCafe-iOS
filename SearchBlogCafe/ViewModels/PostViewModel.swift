//
//  PostViewModel.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/07/01.
//

import Foundation
import RxSwift
import RxCocoa

class PostViewModel: NSObject {
    
    var post = BehaviorRelay<Post>(value: Post.empty)
    
    init(_ post: Post) {
        BehaviorSubject<Post>.just(post)
            .take(1)
            .subscribe(onNext: self.post.accept(_:))
    }
    
    lazy var typeString: Observable<String> = self.post.map {
        if $0.type == .blog { return "Blog" }
        if $0.type == .cafe { return "Cafe" }
        return ""
    }
    
    lazy var alpha: Observable<Double> = post.map { $0.isRead ? 0.3 : 1.0 }
    lazy var thumbnailData: Observable<Data?> = post.map {
        var data: Data?
        if let url = URL(string: $0.thumbnail) {
            do {
                data = try Data(contentsOf: url)
            } catch {
                print("Failed to get thumbnail data from url. error = \(error.localizedDescription)")
            }
        }
        return data
    }
    
    func formatDate(style: DateUtil.FormatStyle) -> Observable<String> {
        post.map {
            guard let date = DateUtil.parseDate($0.date) else { return "" }
            return DateUtil.formatDate(date, style: style)
        }
    }
}
