//
//  KakaoService.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/07/01.
//

import Foundation
import Alamofire
import RxSwift

class KakaoService {
    private static let key = "01b3aab474678c48ee8aac5c31d2de83"
    private static let size = 25
    
    static let cafeURL = "https://dapi.kakao.com/v2/search/cafe"
    static let blogURL = "https://dapi.kakao.com/v2/search/blog"
    
    /* Kakao 검색 */
    private static func searchPosts(from url: String, for keyword: String, page: Int,
                                    completion: @escaping (Result<Data, Error>) -> ()) {
        let headers: HTTPHeaders = [
            "Authorization": "KakaoAK \(key)"
        ]
        
        let parameters: [String: Any] = [
            "query": keyword,
            "size": size,
            "page": page
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        let httpResponse = response.error as! HTTPURLResponse
                        completion(.failure(NSError(domain: "no data",
                                                    code: httpResponse.statusCode,
                                                    userInfo: nil)))
                        return
                    }
                    completion(.success(data))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            })
    }
    
    static func searchPostsRx(from url: String, for keyword: String, page: Int) -> Observable<Data> {
        return Observable.create { emitter in
            searchPosts(from: url, for: keyword, page: page) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                    emitter.onCompleted()
                case .failure(let err):
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
}
