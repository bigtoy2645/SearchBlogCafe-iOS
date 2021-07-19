//
//  DetailViewController.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/29.
//

import UIKit
import RxSwift

class DetailViewController: UIViewController {
    
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contents: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var url: UILabel!
    @IBOutlet weak var imageContentConstraint: NSLayoutConstraint!
    
    static let storyboardID = "DetailView"
    
    var delegate: DetailDelegate?
    var indexPath: IndexPath?
    var viewModel = PostViewModel(Post.empty)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Binding
        setupBinding()
    }
    
    // MARK: - UI Binding
    
    func setupBinding() {
        viewModel.typeString
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.title = $0
            })
            .disposed(by: disposeBag)
        
        viewModel.post.map { $0.name }
            .observe(on: MainScheduler.instance)
            .bind(to: name.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.formatDate(style: .long)
            .observe(on: MainScheduler.instance)
            .bind(to: date.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.post.map { $0.title }
            .observe(on: MainScheduler.instance)
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.post.map { $0.contents }
            .observe(on: MainScheduler.instance)
            .bind(to: contents.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.post.map { $0.url }
            .observe(on: MainScheduler.instance)
            .bind(to: url.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.thumbnailData
            .observe(on: MainScheduler.instance)
            .map { data -> UIImage? in
                guard let data = data else {
                    self.thumbnail.isHidden = true
                    self.imageContentConstraint.isActive = false
                    return nil
                }
                self.thumbnail.layer.cornerRadius = 8
                self.thumbnail.isHidden = false
                self.imageContentConstraint.isActive = true
                return UIImage(data: data)
            }
            .bind(to: thumbnail.rx.image)
            .disposed(by: disposeBag)
    }
    
    /* URL로 이동 */
    @IBAction func linkButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: PostViewController.segueID, sender: viewModel.post)
        delegate?.didOpenURL(indexPath: indexPath)
    }
    
    /* PostViewController 설정 */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PostViewController.segueID,
           let postVC = segue.destination as? PostViewController {
            do {
                try postVC.viewModel = PostViewModel(viewModel.post.value())
            } catch {
                print("no post data. \(error.localizedDescription)")
            }
        }
    }
}
