//
//  SearchListTableViewCell.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/28.
//

import UIKit
import RxSwift
import RxCocoa

class PostListTableViewCell: UITableViewCell {
    
    static let nibName = "PostListTableViewCell"
    static let cellID = "PostCell"
    
    @IBOutlet weak var type: UILabel!  // Blog/Cafe
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    var viewModel = PostViewModel(Post.empty)
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 이미지 둥글게
        self.thumbnail.layer.cornerRadius = 8
    }
    
    func bind(post: Post) {
        viewModel = PostViewModel(post)
        
        // UI Binding
        setupBindings()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    // MARK: - UI Binding
    
    func setupBindings() {
        viewModel.typeString
            .observe(on: MainScheduler.instance)
            .bind(to: type.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.post
            .map { $0.title }
            .observe(on: MainScheduler.instance)
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.formatDate(style: .short)
            .observe(on: MainScheduler.instance)
            .bind(to: date.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.thumbnailData
            .map { data -> UIImage? in
                guard let data = data else {
                    self.thumbnail.isHidden = true
                    return nil
                }
                self.thumbnail.isHidden = false
                return UIImage(data: data)
            }
            .observe(on: MainScheduler.instance)
            .bind(to: thumbnail.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.post
            .map { $0.name }
            .observe(on: MainScheduler.instance)
            .bind(to: name.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.alpha
            .map { CGFloat($0) }
            .bind(to: contentView.rx.alpha)
            .disposed(by: disposeBag)
    }
}
