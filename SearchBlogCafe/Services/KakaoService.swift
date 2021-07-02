//
//  KakaoService.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/07/01.
//

import Foundation
import Alamofire

class KakaoService {
    private let key = "01b3aab474678c48ee8aac5c31d2de83"
    private let cafeURL = "https://dapi.kakao.com/v2/search/cafe"
    private let blogURL = "https://dapi.kakao.com/v2/search/blog"
    private let size = 25
    
    func searchBlogPosts(for keyword: String, page: Int, completion: @escaping ([Post]?) -> ()) {
        let headers: HTTPHeaders = [
            "Authorization": "KakaoAK \(key)"
        ]
        
        let parameters: [String: Any] = [
            "query": keyword,
            "size": size,
            "page": page
        ]
        
        // Blog 검색
        AF.request(blogURL, method: .get,
                   parameters: parameters, headers: headers)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    if let result = response.data {
                        if let blogData = try? JSONDecoder().decode(BlogPosts.self, from: result) {
                            completion(self.parseJSON(blogData: blogData.documents))
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                }
            })
    }
    
    func searchCafePosts(for keyword: String, page: Int, completion: @escaping ([Post]?) -> ()) {
        let headers: HTTPHeaders = [
            "Authorization": "KakaoAK \(key)"
        ]
        
        let parameters: [String: Any] = [
            "query": keyword,
            "size": size,
            "page": page
        ]
        
        // Cafe 검색
        AF.request(cafeURL, method: .get,
                   parameters: parameters, headers: headers)
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    if let result = response.data {
                        if let cafeData = try? JSONDecoder().decode(CafePosts.self, from: result) {
                            completion(self.parseJSON(cafeData: cafeData.documents))
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                }
            })
    }
    
    /* [Blog] -> [Post] */
    private func parseJSON(blogData: [Blog]) -> [Post] {
        var blogPosts = [Post]()
        
        for data in blogData {
            let post = Post(type: Filter.blog,
                            name: data.blogname,
                            contents: data.contents,
                            date: data.datetime,
                            thumbnail: data.thumbnail,
                            title: data.title,
                            url: data.url)
            blogPosts.append(post)
        }
        
        return blogPosts
    }
    
    /* [Cafe] -> [Post] */
    private func parseJSON(cafeData: [Cafe]) -> [Post] {
        var cafePosts = [Post]()
        
        for data in cafeData {
            let post = Post(type: Filter.cafe,
                            name: data.cafename,
                            contents: data.contents,
                            date: data.datetime,
                            thumbnail: data.thumbnail,
                            title: data.title,
                            url: data.url)
            cafePosts.append(post)
        }
        
        return cafePosts
    }
}
