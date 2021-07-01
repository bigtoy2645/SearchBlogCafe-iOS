//
//  String+Html.swift
//  SearchBlogCafe
//
//  Created by yurim on 2021/06/30.
//

import Foundation

extension String {
    
    /* HTML 폰트 사이즈 적용 */
    func appendHtmlFont(size: Int) -> String {
        return String(format:"<span style=\"font-size: \(size);\">%@</span>", self)
    }
    
    /* HTML 적용한 NSAttributedString */
    func htmlAttributedString() -> NSAttributedString {
        do {
            guard let data = self.data(using: .utf16) else { return NSAttributedString(string: self) }
            let attributedString = try NSAttributedString(data: data,
                                                          options: [.documentType: NSAttributedString.DocumentType.html],
                                                          documentAttributes: nil)
            return attributedString
        } catch {
            return NSAttributedString(string: self)
        }
    }
    
    /* HTML 태그 제거 */
    func htmlEscaped() -> String {
        guard let encodedData = self.data(using: .utf16) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf16.rawValue
        ]
        
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: options, documentAttributes: nil)
            return attributedString.string
        } catch {
            return self
        }
    }
}
